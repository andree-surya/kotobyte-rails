
CREATE_TABLES_SQL = <<-EOS
create table words (id integer primary key, serialized blob not null);
create table kanji (id integer primary key, serialized blob not null);

create virtual table literals_fts using fts5(text, word_id unindexed, priority unindexed);
create virtual table senses_fts using fts5(text, word_id unindexed, tokenize='unicode61');
create virtual table kanji_fts using fts5(character, kanji_id unindexed);
EOS

SEARCH_WORDS_SQL = <<-EOS
with search_results as (%s)
  select id, serialized, group_concat(highlight, ';') highlights, min(score) score
  from words join search_results on (id = word_id) group by id order by score;
EOS

SEARCH_LITERALS_SQL = SEARCH_WORDS_SQL % <<-EOS
select word_id,  highlight(literals_fts, 0, '{', '}') highlight, rank * length(snippet(literals_fts, 0, '', '', '', 1)) score
  from literals_fts(?) order by score, rank * priority limit ?
EOS

SEARCH_SENSES_SQL = SEARCH_WORDS_SQL % <<-EOS
select word_id, highlight(senses_fts, 0, '{', '}') highlight, rank score
  from senses_fts(?) order by score limit ?
EOS

SEARCH_KANJI_SQL = <<-EOS
select id, character, serialized from kanji join kanji_fts(?) on (id = kanji_id) limit ?;
EOS

#
# Dictionary SQLite3 database interface
#
class DictionaryDatabase

  #
  # Create new dictionary database instance
  #
  # @param [<String>] file Database file path
  # @param [<Boolean>] reset Destroy and reinitialize database structure?
  #
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

    @database.execute_batch CREATE_TABLES_SQL if should_reset_structures
  end

  #
  # Execute a database transaction
  #
  # @yield [<DictionaryDatabase>]
  #
  def transaction
    @database.transaction { yield self }
  end

  #
  # Optimize database internal structure
  #
  def optimize
    @database.execute 'VACUUM'
  end

  #
  # Register a new Word entry
  #
  # @param [<Word>]
  #
  def insert_word(word)
    word = word.clone
    word_id = word.id

    @index_sense ||= @database.prepare('insert into senses_fts values (?, ?)')
    @index_literal ||= @database.prepare('insert into literals_fts values (?, ?, ?)')
    @insert_word ||= @database.prepare('insert into words values (?, ?)')

    word.literals.each do |literal| 
      @index_literal.execute(literal.text, word_id, literal.priority)
    end

    word.readings.each do |reading| 
      @index_literal.execute(reading.text, word_id, reading.priority) 
    end

    word.senses.each do |sense|
      @index_sense.execute(sense.texts.join(';'), word_id)
    end

    # We can derive ID from table ID.
    word.id = 0

    @insert_word.execute(word_id, Word.encode(word))
  end

  #
  # Register a new Kanji entry
  #
  # @param [<Kanji>]
  #
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

  #
  # Search Word entries matching the given query string
  #
  # @param [<String>] query Query string
  #
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

  #
  # Search Kanji entries matching the given query string
  #
  # @param [<String>] query Query string
  # @param [<Integer>] limit Limit number of entries returned
  #
  def search_kanji(query, limit = 10)
    
    tokens = query.chars.select { |c| c.kanji? }
    results = []

    if tokens.present?
      @search_kanji ||= @database.prepare(SEARCH_KANJI_SQL)

      rows = @search_kanji.execute(tokens.join(' OR '), limit).to_a
    end

    rows.map do |row|
      kanji = Kanji.decode(row['serialized'])

      kanji.character = row['character']
      kanji.id = row['id'].to_i

      kanji
    end
  end

  private

    def search_words_by_literals(query, limit)

      query = query.chars.select { |c| c.kanji? || c.kana? }.join
      tokens = [query]

      case
      when query.contains_hiragana?
        tokens += (@lexeme_stemmer ||= LexemeStemmer.new).stem(query)

      when query.contains_kanji?
        tokens += (@ngram_tokenizer ||= NGramTokenizer.new).tokenize(query)
      end

      @search_literals ||= @database.prepare(SEARCH_LITERALS_SQL)
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

      @search_senses ||= @database.prepare(SEARCH_SENSES_SQL)
      rows = @search_senses.execute(query.gsub(/[^[[:alnum:]]]/, ' '), limit).to_a

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