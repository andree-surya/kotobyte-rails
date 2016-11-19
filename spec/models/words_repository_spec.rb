
describe WordsRepository do

  let (:repository) do
    WordsRepository.new
  end

  describe '#save_all' do
    it 'should be able to perform bulk indexing operation' do

      words = WordsSourceReader.new.read_all

      repository.create_index! force: true
      repository.save_all(words)

      expect(repository.count).to eq(words.count)
    end
  end

  describe '#deserialize' do
    let(:hash) do
      {
        '_score' => 3.4233,
        '_source' => {
          'literals' => [
            { 'text' => '食べ過ぎる' },
            { 'text' => '食べのこす' }
          ],

          'readings' => [
            { 'text' => 'たべすぎる' },
            { 'text' => 'たべのこす' }
          ],

          'senses' => [
            { 'text' => 'to overeat' },
            { 'text' => 'to left a dish half eaten' }
          ]
        },

        'highlight' => {
          'literals.text' => ['{食べ}過ぎる', '{食べ}{のこす}'],
          'literals.text.raw' => ['{食べのこす}'],

          'readings.text' => ['{たべ}すぎる', '{たべ}{のこす}'],
          'readings.text.raw' => ['{たべのこす}'],

          'senses.text' => ['to {overeat}', 'to left a dish half {eaten}']
        }
      }
    end
    
    let(:word) { repository.deserialize(hash) }

    it 'should parse score information' do
      expect(word.score).to eq(hash['_score'])
    end

    it 'should parse highlighted literals' do
      expect(word.literals[0].text).to eq('{食べ}過ぎる')
      expect(word.literals[1].text).to eq('{食べのこす}')
    end

    it 'should parse highlighted readings' do
      expect(word.readings[0].text).to eq('{たべ}すぎる')
      expect(word.readings[1].text).to eq('{たべのこす}')
    end

    it 'should parse highlighted senses' do
      expect(word.senses[0].text).to eq('to {overeat}')
      expect(word.senses[1].text).to eq('to left a dish half {eaten}')
    end
  end

  describe '#search_words' do
    it 'should search words with the given query string' do

      words = []
      words << Word.new({ 'literals' => [{ 'text' => '言葉' }] })
      words << Word.new({ 'readings' => [{ 'text' => 'げんご' }] })
      words << Word.new({ 'senses' => [{ 'text' => 'word' }] })

      repository.create_index! force: true
      repository.save_all(words)

      expect(repository.search_words('word').count).to eq(1)
      expect(repository.search_words('gengo').count).to eq(1)
      expect(repository.search_words('げんご').count).to eq(1)
      expect(repository.search_words('言葉').count).to eq(1)
    end

    it 'should return no more than the maximum number of results' do

      words = []
      literal = '言語'
      number_of_entries = WordsRepository::MAX_RESULTS + 1
      
      number_of_entries.times do
        words << Word.new({ 'literals' => [{ 'text' => literal }] })
      end

      repository.create_index! force: true
      repository.save_all(words)

      results_count = repository.search_words(literal).count
      expect(results_count).to eq(WordsRepository::MAX_RESULTS)
    end
  end
end

