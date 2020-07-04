
words_source_file = 'tmp/jmdict_e.xml'
kanji_source_file = 'tmp/kanjidic2.xml'
kanji_strokes_file = 'tmp/kanjivg.xml'
sentences_file = 'tmp/sentences.csv'
sentences_idx_file = 'tmp/sentences_idx.csv'

namespace :dict do

  desc 'Download all data source files'
  task prepare: [
    :download_words_source,
    :download_kanji_source,
    :download_kanji_strokes,
    :download_sentences_source,
    :download_sentences_idx
  ]

  desc 'Download words source file'
  task download_words_source: :environment do
    
    `curl -sL http://ftp.monash.edu.au/pub/nihongo/JMdict_e.gz \
      | gunzip -c > #{words_source_file}`
  end

  desc 'Download Kanji source file'
  task download_kanji_source: :environment do

    `curl -sL http://www.edrdg.org/kanjidic/kanjidic2.xml.gz \
      | gunzip -c > #{kanji_source_file}`
  end

  desc 'Download Kanji strokes file'
  task download_kanji_strokes: :environment do

    `curl -sL https://github.com/KanjiVG/kanjivg/releases/download/r20160426/kanjivg-20160426.xml.gz \
      | gunzip -c > #{kanji_strokes_file}`
  end

  desc 'Download sentences source file'
  task download_sentences_source: :environment do
    
    `curl -sL http://downloads.tatoeba.org/exports/sentences.tar.bz2 \
      | tar -xjO sentences.csv | grep -E "^[0-9[:blank:]]+(jpn|eng)" > #{sentences_file}`
  end
  
  desc 'Download sentences index file'
  task download_sentences_idx: :environment do

    `curl -sL http://downloads.tatoeba.org/exports/jpn_indices.tar.bz2 \
      | tar -xjO jpn_indices.csv > #{sentences_idx_file}`
  end

  desc 'Create dictionary database file'
  task create: :environment do
    
    database = DictionaryDatabase.new(reset: true)
    
    words_source_reader = WordsSourceReader.new(
        source_xml: IO.read(words_source_file)
    )
    
    kanji_source_reader = KanjiSourceReader.new(
        source_xml: IO.read(kanji_source_file),
        strokes_xml: IO.read(kanji_strokes_file)
    )
    
    sentences_source_reader = SentencesSourceReader.new(
        source_csv: IO.read(sentences_file),
        indices_csv: IO.read(sentences_idx_file)
    )
    
    database.transaction do |db|
    
      words_source_reader.read_each { |w| db.insert_word(w) }
      kanji_source_reader.read_all.each { |k| db.insert_kanji(k) }
      sentences_source_reader.read_all.each { |s| db.insert_sentence(s) }
    end
    
    database.optimize
  end
end
