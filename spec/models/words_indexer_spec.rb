require 'rails_helper'

describe WordsIndexer do

  let(:source_reader) { double(WordsSourceReader) }
  let(:repository) { double(WordsRepository) }
  let(:logger) { double(Logger).as_null_object }

  let(:indexer) do
    WordsIndexer.new(
      source_reader: source_reader,
      repository: repository,
      logger: logger
    )
  end

  it 'should index all objects in batch' do 
    
    dummy_objects = 4.times.map { double(Word) }
    indexer.batch_size = dummy_objects.count - 1

    expectation = expect(source_reader).to receive(:read_each)
    dummy_objects.each { |object| expectation.and_yield(object) }
    
    expect(repository).to receive(:create_index!).with(force: true)
    expect(repository).to receive(:save_all).with(dummy_objects[0..-2])
    expect(repository).to receive(:save_all).with([dummy_objects.last])
    
    indexer.run
  end
end
