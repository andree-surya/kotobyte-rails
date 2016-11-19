
describe KanjiRepository do

  let (:repository) do
    KanjiRepository.new
  end

  describe '#save_all' do
    it 'should be able to perform bulk indexing operation' do
      
      kanji_list = KanjiSourceReader.new.read_all
      
      repository.create_index! force: true
      repository.save_all(kanji_list)

      expect(repository.count).to eq(kanji_list.count)
    end
  end

  describe '#search' do
    it 'should be able to perform search on kanji literal' do

      kanji_list = []
      kanji_list << Kanji.new({ 'literal' => '茶' })
      kanji_list << Kanji.new({ 'literal' => '水' })
      kanji_list << Kanji.new({ 'literal' => '天' })

      repository.create_index! force: true
      repository.save_all(kanji_list)

      search_result = repository.search('水')
      expect(search_result.count).to eq(1)
      expect(search_result.first.literal).to eq('水')
    end
  end
end

