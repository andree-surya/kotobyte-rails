
describe DictionaryDatabase do
  let(:database) { DictionaryDatabase.new(file: ':memory:') }

  describe '#initialize' do
    let(:database_file) { Rails.configuration.app[:database_file] }

    before(:each) do
        File.delete(database_file) if File.exists? database_file
    end

    it 'should open database file without modification by default' do
      dummy_text = 'This is a dummy text'
      IO.write(database_file, dummy_text)

      DictionaryDatabase.new(file: database_file)
      expect(IO.read(database_file)).to eq(dummy_text)
    end

    it 'should reset database file if requested' do
      dummy_text = 'This is a dummy text'
      IO.write(database_file, dummy_text)

      DictionaryDatabase.new(file: database_file, reset: true)
      expect(IO.read(database_file)).not_to eq(dummy_text)
    end
  end

  describe '#insert_word' do

    it 'should insert all words in the test source file without error' do

      words_source_reader = WordsSourceReader.new(
          source_xml: IO.read(WORDS_SOURCE_FILE)
      )

      database.transaction do |db|
        words_source_reader.read_each { |word| db.insert_word(word) }
      end
    end
  end

  describe '#insert_kanji' do

    it 'should insert all Kanji in the test source file without error' do

      kanji_source_reader = KanjiSourceReader.new(
          source_xml: IO.read(KANJI_SOURCE_FILE),
          strokes_xml: IO.read(KANJI_STROKES_FILE)
      )

      database.transaction do |db|
        kanji_source_reader.read_all.map { |kanji| db.insert_kanji(kanji) }
      end
    end
  end

  describe '#insert_sentence' do

    it 'should insert all sentences in the test source file without error' do

      sentence_source_reader = SentencesSourceReader.new(
          source_csv: IO.read(SENTENCES_SOURCE_FILE),
          indices_csv: IO.read(SENTENCES_INDICES_FILE)
      )

      database.transaction do |db|
        sentence_source_reader.read_all.map { |sentence| db.insert_sentence(sentence) }
      end
    end
  end

  describe '#search_words' do

    it 'should look-up words by literals' do
      
      database.insert_word(Word.new(id: 100, literals: { text: '片付ける' }))
      database.insert_word(Word.new(id: 200, literals: { text: '片付く' }))
      database.insert_word(Word.new(id: 300, literals: { text: '関係ない事' }))

      response = database.search_words('片付けますよ')
      
      expect(response.words.count).to eq(2)
      expect(response.words[0].id).to eq(100)
      expect(response.words[1].id).to eq(200)
      expect(response.words[0].literals.first.text).to eq('{片付ける}')
      expect(response.words[1].literals.first.text).to eq('{片付く}')
    end

    it 'should look-up words by Romaji readings' do

      database.insert_word(Word.new(id: 100, readings: { text: 'ことわり' }))
      database.insert_word(Word.new(id: 200, readings: { text: 'バリ' }))

      response = database.search_words('ことわります')

      expect(response.words.count).to eq(1)
      expect(response.words[0].id).to eq(200)
      expect(response.words[0].readings.first.text).to eq('{ことわり}')
    end

    it 'should look-up words by English senses' do

      database.insert_word(Word.new(id: 100, senses: { texts: ['serendipity'] }))
      database.insert_word(Word.new(id: 200, senses: { texts: ['fortunate stroke'] }))

      response = database.search_words('fortunate event')

      expect(response.words.count).to eq(1)
      expect(response.words[0].id).to eq(200)
      expect(response.words[0].senses.first.texts[0]).to eq('{fortunate} stroke')
    end
  end

  describe '#search_kanji' do

    it 'should look-up Kanji characters' do

      database.insert_kanji(Kanji.new(id: 100, character: '空'))
      database.insert_kanji(Kanji.new(id: 200, character: '飛'))
      database.insert_kanji(Kanji.new(id: 300, character: '元'))

      kanji_list = database.search_kanji('青空に飛んで')

      expect(kanji_list.count).to eq(2)
      expect(kanji_list[0].id).to eq('空')
      expect(kanji_list[1].id).to eq('飛')
    end
  end

  describe '#search_sentences' do

    it 'should look-up sentences' do
      
    end
  end
end
