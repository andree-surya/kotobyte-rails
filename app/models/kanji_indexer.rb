
class KanjiIndexer 
  attr_accessor :batch_size

  def initialize(
      source_reader: KanjiSourceReader.new, 
      repository: KanjiRepository.new, 
      logger: Rails.logger)

    @source_reader = source_reader
    @repository = repository
    @logger = logger
  end

  def run
    start_time = Time.now

    @logger.info 'Resetting index ...'
    @repository.create_index! force: true

    kanji_list = @source_reader.read_all
    @repository.save_all(kanji_list)

    message = 'Successfully indexed %d entries in %.03f seconds'
    @logger.info sprintf(message, kanji_list.count, Time.now - start_time) 
  end
end
