
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
    select id, tokenized, serialized from sentences join sentences_fts(?) on (id = sentence_id) limit ?;
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
    word.senses.each { |s| @index_sense.execute(s.texts.join('|'), word_id) }

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

    start_time = Time.now

    if query.contains_japanese?
      results = search_words_by_literals(query, 50)

    else
      results = search_words_by_senses(query, 50)

      if results.size <= 10
        literal_results = []

        literal_results += search_words_by_literals(query.hiragana, 20)
        literal_results += search_words_by_literals(query.katakana, 20)
        literal_results.sort! { |r1, r2| r1['score'] <=> r2['score'] }

        results += literal_results
      end
    end

    finish_time = Time.now

    SearchWordsResponse.new(
      words: results.map { |r| Word.decode(r['serialized']) },
      time: finish_time - start_time
    )
  end

  def search_kanji(query, limit = 10)
    return nil if query.empty?

    tokens = query.chars.select { |c| c.kanji? }

    @search_kanji ||= @database.prepare(@@search_kanji_sql)
    @search_kanji.execute(tokens.join(' OR '), limit).map do |h|

      Kanji.decode(h['serialized'])
    end
  end

  def search_sentences(query, limit = 20) 

    @search_sentences ||= @database.prepare(@@search_sentences_sql)
    @search_sentences.execute(query, limit).map do |h| 

      Sentence.decode(h['serialized'])
    end
  end

  private

    def search_words_by_literals(query, limit)

      query = query.chars.select { |c| c.kanji? || c.kana? }.join
      tokens = 1.upto(query.size).map { |l| query[0...l] << '*' } << query

      @search_literals ||= @database.prepare(@@search_words_sql % @@search_literals_sql)
      @search_literals.execute(tokens.join(' OR '), limit).to_a
    end

    def search_words_by_senses(query, limit)

      @search_senses ||= @database.prepare(@@search_words_sql % @@search_senses_sql)
      @search_senses.execute(query, limit).to_a
    end
end
