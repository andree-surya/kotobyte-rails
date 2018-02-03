
class DictionaryDatabase

  @@create_tables_sql = <<-EOS
    create table words (id integer primary key, serialized blob not null);
    create table kanji (id integer primary key, serialized blob not null);
    create table sentences (id integer primary key, serialized blob not null);

    create virtual table literals_fts using fts5(text, word_id unindexed, priority unindexed, prefix='1 2 3 4');
    create virtual table senses_fts using fts5(text, word_id unindexed, tokenize='porter');
    create virtual table kanji_fts using fts5(character, kanji_id unindexed);
    create virtual table sentences_fts using fts5(tokenized, sentence_id unindexed);
  EOS

  @@search_literals_sql = <<-EOS
    select word_id, highlight(literals_fts, 0, '{', '}') highlight, rank * (priority + 1) score
      from literals_fts(?) order by score limit ?
  EOS

  @@search_senses_sql = <<-EOS
    select word_id, highlight(senses_fts, 0, '{', '}') highlight, rank score
      from senses_fts(?) order by score limit ?
  EOS

  @@search_words_sql = <<-EOS
    with search_results as (%s)
      select id, serialized, group_concat(highlight, ';') highlights, min(score) score
      from words join search_results on (id = word_id) group by id order by score;
  EOS

  @@search_kanji_sql = <<-EOS
    select id, character, serialized from kanji join kanji_fts(?) on (id = kanji_id) limit ?;
  EOS

  @@search_sentences_sql = <<-EOS
    select id, serialized, highlight(sentences_fts, 0, '{', '}') highlight 
      from sentences join sentences_fts(?) on (id = sentence_id) limit ?;
  EOS

  def initialize(file: Rails.configuration.app[:database_file], reset: false)

    should_reset_structures = true

    if File.exists? file
      if reset
        File.delete file
      else
        should_reset_structures = false
      end
    end

    @database = SQLite3::Database.new(file)
    @database.results_as_hash = true

    @database.execute_batch @@create_tables_sql if should_reset_structures
  end

  def transaction
    @database.transaction { yield self }
  end

  def optimize
    @database.execute 'VACUUM'
  end

  def insert_word(word)
    word = word.clone
    word_id = word.id

    @index_sense ||= @database.prepare('insert into senses_fts values (?, ?)')
    @index_literal ||= @database.prepare('insert into literals_fts values (?, ?, ?)')
    @insert_word ||= @database.prepare('insert into words values (?, ?)')

    word.literals.each { |l| @index_literal.execute(l.text, word_id, l.priority) }
    word.readings.each { |r| @index_literal.execute(r.text, word_id, r.priority) }
    word.senses.each { |s| @index_sense.execute(s.texts.join(';'), word_id) }

    # We can derive ID from table ID.
    word.id = 0

    @insert_word.execute(word_id, Word.encode(word))
  end

  def insert_kanji(kanji)
    kanji = kanji.clone
    kanji_id = kanji.id

    @index_kanji ||= @database.prepare('insert into kanji_fts values (?, ?)')
    @insert_kanji ||= @database.prepare('insert into kanji values (?, ?)')
    
    @index_kanji.execute(kanji.character, kanji_id)

    # We can derive these data from FTS table.
    kanji.id = 0
    kanji.character = ''

    @insert_kanji.execute(kanji_id, Kanji.encode(kanji))
  end

  def insert_sentence(sentence)
    sentence = sentence.clone
    sentence_id = sentence.id

    @index_sentence ||= @database.prepare('insert into sentences_fts values (?, ?)')
    @insert_sentence ||= @database.prepare('insert into sentences values (?, ?)')

    @index_sentence.execute(sentence.tokenized, sentence_id)

    # We can derive these data from FTS table.
    sentence.id = 0
    sentence.tokenized = ''

    @insert_sentence.execute(sentence_id, Sentence.encode(sentence))
  end

  def search_words(query)
    query = query.downcase

    if query.contains_japanese?
      words = search_words_by_literals(query, 50)

    else
      words = search_words_by_senses(query, 50)

      if words.size <= 10
        extra_words = []

        extra_words += search_words_by_literals(query.hiragana, 20)
        extra_words += search_words_by_literals(query.katakana, 20)
        extra_words.sort! { |w1, w2| w1.score <=> w2.score }

        words += extra_words
      end
    end

    words
  end

  def search_kanji(query, limit = 10)
    
    tokens = query.chars.select { |c| c.kanji? }
    results = []

    if tokens.present?
      @search_kanji ||= @database.prepare(@@search_kanji_sql)

      rows = @search_kanji.execute(tokens.join(' OR '), limit).to_a
    end

    rows.map do |row|
      kanji = Kanji.decode(row['serialized'])

      kanji.character = row['character']
      kanji.id = row['id'].to_i

      kanji
    end
  end

  def search_sentences(query, limit = 20) 

    @search_sentences ||= @database.prepare(@@search_sentences_sql)
    
    rows = @search_sentences.execute(query, limit).to_a

    rows.map do |row| 
      sentence = Sentence.decode(row['serialized'])

      sentence.tokenized = row['highlight']
      sentence.id = row['id'].to_i

      token_lookup_offset = 0
      text = sentence.original.dup

      sentence.tokenized.split.each do |token|

        is_highlighted = token.include? '{'

        token.gsub!(/[{}]/, '') # Remove highlight markers {, }
        token.gsub!(/\|.*$/, '') # Remove lemma form 為る in する|為る

        token_start_index = text.index(token, token_lookup_offset)

        if token_start_index.present?
          token_end_index = token_start_index + token.length

          if is_highlighted
            text[token_start_index...token_end_index] = "{#{token}}"
          end

          token_lookup_offset = token_end_index
        end
      end

      sentence.original = text

      sentence
    end
  end

  private

    def search_words_by_literals(query, limit)

      query = query.chars.select { |c| c.kanji? || c.kana? }.join
      tokens = 1.upto(query.size).map { |l| query[0...l] << '*' } << query

      @search_literals ||= @database.prepare(@@search_words_sql % @@search_literals_sql)
      rows = @search_literals.execute(tokens.join(' OR '), limit).to_a

      rows.map do |row|
        word = decode_word_from(row: row)
  
        row['highlights'].split(';').each do |highlight|
          raw_text = highlight.gsub(/[{}]/, '') # Remove highlights
          
          word.literals.each do |literal|
            literal.text = highlight if literal.text == raw_text
          end

          word.readings.each do |reading|
            reading.text = highlight if reading.text == raw_text
          end
        end

        word
      end
    end

    def search_words_by_senses(query, limit)

      @search_senses ||= @database.prepare(@@search_words_sql % @@search_senses_sql)
      rows = @search_senses.execute(query, limit).to_a

      rows.map do |row|
        word = decode_word_from(row: row)
  
        row['highlights'].split(';').each do |highlight|
          raw_text = highlight.gsub(/[{}]/, '')

          word.senses.each do |sense|

            for i in 0...sense.texts.count
              sense.texts[i] = highlight if sense.texts[i] == raw_text
            end
          end
        end

        word
      end
    end

    def decode_word_from(row:)

      word = Word.decode(row['serialized'])
      word.score = row['score'].to_f
      word.id = row['id'].to_i

      word
    end
end

class Word
  attr_accessor :score
end