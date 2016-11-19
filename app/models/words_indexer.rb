
class WordsIndexer 
  attr_accessor :batch_size

  def initialize(
      source_reader: WordsSourceReader.new, 
      repository: WordsRepository.new, 
      logger: Rails.logger)

    @source_reader = source_reader
    @repository = repository
    @logger = logger

    @batch_size = 20000
  end

  def run
    words = []
    total_count = 0
    start_time = Time.now

    @logger.info 'Resetting index ...'
    @repository.create_index! force: true

    flush = lambda {
      @repository.save_all(words)
      @logger.debug "Entries indexed: #{total_count}"

      words.clear
    }

    index_from_reader = lambda { |source_reader|

      source_reader.read_each do |word|
        words << word
        total_count += 1

        flush.call if words.size >= @batch_size
      end
    }

    index_from_reader.call(@source_reader)
    flush.call if words.size > 0

    message = 'Successfully indexed %d entries in %.03f seconds'
    @logger.info sprintf(message, total_count, Time.now - start_time) 
  end
end
