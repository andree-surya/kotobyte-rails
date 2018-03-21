
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

      database.insert_word(Word.new(id: 100, literals: [{ text: '片付ける' }]))
      database.insert_word(Word.new(id: 200, literals: [{ text: '片付く' }]))
      database.insert_word(Word.new(id: 300, literals: [{ text: '関係ない事' }]))

      words = database.search_words('片付けます')
      
      expect(words.count).to eq(2)
      expect(words[0].id).to eq(100)
      expect(words[1].id).to eq(200)
      expect(words[0].literals.first.text).to eq('{片付ける}')
      expect(words[1].literals.first.text).to eq('{片付く}')
    end

    it 'should look-up words by readings' do

      database.insert_word(Word.new(id: 100, readings: [{ text: 'ことわり' }]))
      database.insert_word(Word.new(id: 200, readings: [{ text: 'バリ' }]))

      words = database.search_words('ことわります')

      expect(words.count).to eq(1)
      expect(words[0].id).to eq(100)
      expect(words[0].readings.first.text).to eq('{ことわり}')
    end

    it 'should look-up words by Romaji' do

      database.insert_word(Word.new(id: 100, readings: [{ text: 'にぶい' }]))
      database.insert_word(Word.new(id: 200, readings: [{ text: 'わるい' }]))
      database.insert_word(Word.new(id: 300, readings: [{ text: 'ネタバレ' }]))
      database.insert_word(Word.new(id: 400, readings: [{ text: 'デグレ' }]))

      words1 = database.search_words('warukunai')
      words2 = database.search_words('Netabare')

      expect(words1.count).to eq(1)
      expect(words1[0].id).to eq(200)
      expect(words1[0].readings.first.text).to eq('{わるい}')

      expect(words2.count).to eq(1)
      expect(words2[0].id).to eq(300)
      expect(words2[0].readings.first.text).to eq('{ネタバレ}')
    end

    it 'should look-up words by English senses' do

      database.insert_word(Word.new(id: 100, senses: [{ texts: ['serendipity'] }]))
      database.insert_word(Word.new(id: 200, senses: [{ texts: ['a fortunate stroke'] }]))

      words = database.search_words('fortunate')

      expect(words.count).to eq(1)
      expect(words[0].id).to eq(200)
      expect(words[0].senses.first.texts[0]).to eq('a {fortunate} stroke')
    end
  end

  describe '#search_kanji' do

    it 'should look-up Kanji characters' do

      database.insert_kanji(Kanji.new(id: 100, character: '空'))
      database.insert_kanji(Kanji.new(id: 200, character: '飛'))
      database.insert_kanji(Kanji.new(id: 300, character: '元'))

      kanji_list = database.search_kanji('青空に飛んで')

      expect(kanji_list.count).to eq(2)
      expect(kanji_list[0].id).to eq(100)
      expect(kanji_list[1].id).to eq(200)
      expect(kanji_list[0].character).to eq('空')
      expect(kanji_list[1].character).to eq('飛')
    end
  end

  describe '#search_sentences' do

    it 'should look-up and highlight sentences' do
      
      database.insert_sentence(Sentence.new(
        id: 100, 
        original: '「道」という漢字の総画数は何画ですか。',
        tokenized: '道 という|と言う 漢字 総画数 何 画 ですか')
      )

      database.insert_sentence(Sentence.new(
        id: 200, 
        original: '老齢人口は、健康管理にますます多くの出費が必要となるだろう。',
        tokenized: '老齢 人口 健康管理 ますます|益々 多く 出費 必要 となる だろう')
      )

      database.insert_sentence(Sentence.new(
        id: 300, 
        original: '彼らはおおいに努力したが結局失敗した。',
        tokenized: '彼ら おおいに|大いに 努力 した|為る 結局 失敗 した|為る')
      )

      sentences1 = database.search_sentences('大いに')
      sentences2 = database.search_sentences('道')
      sentences3 = database.search_sentences('ますます')

      expect(sentences1.count).to eq(1)
      expect(sentences1.first.id).to eq(300)
      expect(sentences1.first.original).to eq('彼らは{おおいに}努力したが結局失敗した。')

      expect(sentences2.count).to eq(1)
      expect(sentences2.first.id).to eq(100)
      expect(sentences2.first.original).to eq('「{道}」という漢字の総画数は何画ですか。')

      expect(sentences3.count).to eq(1)
      expect(sentences3.first.id).to eq(200)
      expect(sentences3.first.original).to eq('老齢人口は、健康管理に{ますます}多くの出費が必要となるだろう。')
    end
  end

  describe '#search_sentences_by_word' do

    it 'should look-up sentences given a word' do

      word = Word.new(
        literals: [{ text: '{食べる}', priority: 2 }, { text: '食らう' }],
        readings: [{ text: 'たべる', priority: 2 }, { text: '{くらう}' }]
      )

      expected_limit = 5
      expected_query = (['食べる'] * 4 + ['食らう'] * 2 + ['たべる'] * 3 + ['くらう']).join(' OR ')
      expect(database).to receive(:search_sentences).with(expected_query, expected_limit)

      database.search_sentences_by_word(word, expected_limit)
    end
  end
end
