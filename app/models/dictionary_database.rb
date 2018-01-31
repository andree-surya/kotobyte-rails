
class DictionaryDatabase

  @@create_tables_sql = <<-EOS

    create table words (
      id integer primary key,
      json text not null
    );

    create table kanji (
      id integer primary key,
      json text not null
    );

    create table sentences (
      id integer primary key,
      original text not null,
      tokenized text not null,
      translated text not null
    );
  EOS

  @@build_indexes_sql = <<-EOS
    create virtual table literals_fts using fts5(text, word_id unindexed, priority unindexed, prefix='1 2 3 4 5');
    create virtual table senses_fts using fts5(text, word_id unindexed, tokenize='porter');
    create virtual table kanji_fts using fts5(text, kanji_id unindexed);
    create virtual table sentences_fts using fts5(text, sentence_id unindexed);

    insert into literals_fts select substr(value, 2), words.id, substr(value, 1, 1) from words, json_each(words.json, '$[0]') where type = 'text';
    insert into literals_fts select substr(value, 2), words.id, substr(value, 1, 1) from words, json_each(words.json, '$[1]') where type = 'text';
    insert into senses_fts select json_extract(value, '$[0]'), words.id from words, json_each(words.json, '$[2]');
    insert into kanji_fts select json_extract(json, '$[0]'), kanji.id from kanji;
    insert into sentences_fts select tokenized, sentences.id from sentences;
  EOS

  @@search_literals_sql = <<-EOS
    select word_id, highlight(literals_fts, 0, '{', '}') highlight, rank * priority score
      from literals_fts(?) order by score limit ?
  EOS

  @@search_senses_sql = <<-EOS
    select word_id, highlight(senses_fts, 0, '{', '}') highlight, rank score
      from senses_fts(?) order by score limit ?
  EOS

  @@search_words_sql = <<-EOS
    with search_results as (%s)
      select id, json, group_concat(highlight, ';') highlights, min(score) score
      from words join search_results on (id = word_id) group by id order by score;
  EOS

  @@search_kanji_sql = <<-EOS
    select id, json from kanji join kanji_fts(?) on (id = kanji_id) limit ?;
  EOS

  @@search_sentences_sql = <<-EOS
    select id, original, tokenized, translated from sentences join sentences_fts(?) on (id = sentence_id) limit ?;
  EOS

  def initialize(database_path, reset: false)
    should_reset_structures = true

    if File.exists? database_path
      if reset
        File.delete database_path
      else
        should_reset_structures = false
      end
    end

    @database = SQLite3::Database.new(database_path)
    @database.results_as_hash = true

    @database.execute_batch @@create_tables_sql if should_reset_structures
  end

  def transaction
    @database.transaction { yield self }
  end

  def build_indexes
    @database.execute_batch @@build_indexes_sql
  end

  def optimize
    @database.execute 'VACUUM'
  end

  def insert_word(word)
    @insert_word ||= @database.prepare('insert into words values (?, ?)')
    @insert_word.execute(word.id, json_from_word(word))
  end

  def insert_kanji(kanji)
    @insert_kanji ||= @database.prepare('insert into kanji values (?, ?)')
    @insert_kanji.execute(kanji.id, json_from_kanji(kanji))
  end

  def insert_sentence(sentence)
    @insert_sentence ||= @database.prepare('insert into sentences values (?, ?, ?, ?)')
    @insert_sentence.execute(sentence.id, sentence.original, sentence.tokenized, sentence.translated)
  end

  def search_words(query)

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

    results.each { |r| r['json'] = r['json'][0...32] }
    results
  end

  def search_kanji(query, limit = 10)
    results = []

    tokens = query.chars.select { |c| c.kanji? }

    unless query.empty?
      @search_kanji ||= @database.prepare(@@search_kanji_sql)
      @search_kanji.execute(tokens.join(' OR '), limit).each { |h| results << h }
    end

    results
  end

  def search_sentences(query, limit = 100) 
    results = []

    @search_sentences ||= @database.prepare(@@search_sentences_sql)
    @search_sentences.execute(query, limit).each { |h| results << h }
  
    results
  end

  private

    def search_words_by_literals(query, limit)
      results = []

      query = query.chars.select { |c| c.kanji? || c.kana? }.join
      tokens = 1.upto(query.size).map { |l| query[0...l] << '*' } << query

      @search_literals ||= @database.prepare(@@search_words_sql % @@search_literals_sql)
      @search_literals.execute(tokens.join(' OR '), limit).each { |h| results << h }

      results
    end

    def search_words_by_senses(query, limit)
      results = []

      @search_senses ||= @database.prepare(@@search_words_sql % @@search_senses_sql)
      @search_senses.execute(query, limit).each { |h| results << h }

      results
    end

    def json_from_word(word)
      [
        word.literals&.map { |l| "#{l.priority}#{l.text}" } || 0,
        word.readings.map { |r| "#{r.priority}#{r.text}" },

        word.senses.map do |s|
          [
            s.texts.join(', '),
            s.categories&.join(';') || 0,
            s.origins&.join(';') || 0,
            s.labels&.join(';') || 0,
            s.notes&.join(';') || 0
          ]
        end

      ].to_json
    end

    def json_from_kanji(kanji)
      [
        kanji.character,
        kanji.readings&.join(';') || 0,
        kanji.meanings&.join(';') || 0,
        kanji.jlpt || 0,
        kanji.grade || 0,
        kanji.strokes&.join(';') || 0

      ].to_json
    end
end
