require 'rails_helper'

describe KanjiIndexer do

  let(:source_reader) { double(KanjiSourceReader) }
  let(:repository) { double(KanjiRepository) }
  let(:logger) { double(Logger).as_null_object }

  let(:indexer) do
    KanjiIndexer.new(
      source_reader: source_reader, 
      repository: repository,
      logger: logger
    )
  end

  it 'should index all objects' do 
    
    dummy_objects = 4.times.map { double(Kanji) }

    expect(source_reader).to receive(:read_all).and_return(dummy_objects)
    expect(repository).to receive(:create_index!).with(force: true)
    expect(repository).to receive(:save_all).with(dummy_objects)
    
    indexer.run
  end
end
