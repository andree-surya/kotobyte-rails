
words_source_file = 'vendor/data/jmdict_e.xml'
kanji_source_file = 'vendor/data/kanjidic2.xml'
kanji_strokes_file = 'vendor/data/kanjivg.xml'

namespace :dict do

  desc 'Download all data source files'
  task download: [
    :download_words_source,
    :download_kanji_source,
    :download_kanji_strokes
  ]

  desc 'Download words source file'
  task download_words_source: :environment do
    
    `curl -sL ftp://ftp.edrdg.org/pub/Nihongo//JMdict_e.gz \
      | gunzip -c > #{words_source_file}`
  end

  desc 'Download Kanji source file'
  task download_kanji_source: :environment do

    `curl -sL http://www.edrdg.org/kanjidic/kanjidic2.xml.gz \
      | gunzip -c > #{kanji_source_file}`
  end

  desc 'Download Kanji strokes file'
  task download_kanji_strokes: :environment do

    `curl -sL https://github.com/KanjiVG/kanjivg/releases/download/r20220427/kanjivg-20220427.xml.gz \
      | gunzip -c > #{kanji_strokes_file}`
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
    
    database.transaction do |db|
    
      words_source_reader.read_each { |w| db.insert_word(w) }
      kanji_source_reader.read_all.each { |k| db.insert_kanji(k) }
    end
    
    database.optimize
  end
end
