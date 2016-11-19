
class KanjiRepository
  include Elasticsearch::Persistence::Repository

  def initialize

    klass Kanji
    index Rails.configuration.app[:kanji_index_name]

    settings do 
      mapping dynamic: 'strict' do
        indexes :id, type: 'integer', index: 'no'
        indexes :literal, type: 'string', index: 'not_analyzed'
        indexes :readings, type: 'string', index: 'no'
        indexes :meanings, type: 'string', index: 'no'
        indexes :jlpt, type: 'byte', index: 'no'
        indexes :grade, type: 'byte', index: 'no'
        indexes :strokes, type: 'string', index: 'no'
      end
    end
  end

  def count(body = { query: { match_all: {} } })  
    search(body, search_type: :query_then_fetch, size: 0).response.hits.total
  end
  
  def save_all(kanji_list)
    index_commands = kanji_list.map do |kanji|
      { index: { _id: kanji.id, data: serialize(kanji) } }
    end

    process_response(client.bulk(
      index: index, 
      type: type,
      refresh: true, 
      body: index_commands
    ))
  end

  private

    def process_response(response)

      if response['errors']
        raise response.to_s
      end

      response
    end
end
