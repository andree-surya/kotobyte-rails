require 'core_ext/string'

class WordsRepository
  include Elasticsearch::Persistence::Repository

  MAX_RESULTS = 50
  HIGHLIGHT_START_TAG = '{'
  HIGHLIGHT_END_TAG = '}'

  def initialize
   
    klass Word
    index Rails.configuration.app[:words_index_name]

    settings do 
      mapping dynamic: 'strict' do
        indexes :id, type: 'long', index: 'no'
        indexes :priority, type: 'integer'

        indexes :literals do
          indexes :text, type: 'string', analyzer: 'kuromoji', fields: {
            'raw' => { type: 'string', index: 'not_analyzed' }
          }

          indexes :status, type: 'string', index: 'no'
        end

        indexes :readings do
          indexes :text, type: 'string', analyzer: 'kuromoji', fields: {
            'raw' => { type: 'string', index: 'not_analyzed' }
          }

          indexes :status, type: 'string', index: 'no'
        end

        indexes :senses do
          indexes :text, type: 'string', analyzer: 'standard'
          indexes :categories, type: 'string', index: 'no'
          indexes :sources, type: 'string', index: 'no'
          indexes :labels, type: 'string', index: 'no'
          indexes :notes, type: 'string', index: 'no'
        end
      end
    end
  end
  
  def count(body = { query: { match_all: {} } })  
    search(body, search_type: :query_then_fetch, size: 0).response.hits.total
  end

  def save_all(words)
    index_commands = words.map do |word|
      { index: { _id: word.id, data: serialize(word) } }
    end

    process_response(client.bulk(
      index: index, 
      type: type,
      refresh: true, 
      body: index_commands
    ))
  end

  def search_words(query)
    builder = SearchBodyBuilder.new

    if query.contains_japanese?
      builder.add('literals.text', query: query )
      builder.add('literals.text.raw', query: query, boost: 3)
    
      builder.add('readings.text', query: query)
      builder.add('readings.text.raw', query: query, boost: 3)

    else
      normalized = query.downcase
      hiraganized = normalized.hiragana
      katakanized = normalized.katakana
      
      builder.add('senses.text', normalized)

      if hiraganized.hiragana?
        builder.add('readings.text', query: hiraganized, boost: 1.5)
        builder.add('readings.text.raw', query: hiraganized, boost: 3)
      end

      if katakanized.katakana?
        builder.add('readings.text', query: katakanized, boost: 1.5)
        builder.add('readings.text.raw', query: katakanized, boost: 3)
      end
    end

    body = builder.build
    results = search(body)

    results
  end
  
  def deserialize(document)
    word = Word.new(document['_source'])

    word.score = document['_score']
    highlights = document['highlight']

    if highlights.present?
      
      literal_highlights = []
      literal_highlights += highlights['literals.text'] || []
      literal_highlights += highlights['literals.text.raw'] || []
      
      reading_highlights = []
      reading_highlights += highlights['readings.text'] || []
      reading_highlights += highlights['readings.text.raw'] || []

      override_highlighted_texts(word.literals, literal_highlights)
      override_highlighted_texts(word.readings, reading_highlights)
      override_highlighted_texts(word.senses, highlights['senses.text'] || [])
    end

    word
  end

  private

    def process_response(response)

      if response['errors']
        raise response.to_s
      end

      response
    end

    def override_highlighted_texts(literals, highlights)
      replacements = {}

      highlights.each do |highlight|
        original_text = highlight.dup

        original_text.gsub!(HIGHLIGHT_START_TAG, '')
        original_text.gsub!(HIGHLIGHT_END_TAG, '')

        replacements[original_text] = highlight
      end

      literals.each do |literal|
        if replacements.has_key? literal.text
          literal.text = replacements[literal.text]
        end
      end
    end

    class SearchBodyBuilder
      
      def initialize
        @match_clauses = []
        @highlight_clauses = {}
      end

      def add(field, query)
        @match_clauses << { 
          match: { field => query } 
        }

        @highlight_clauses[field] = { 
          fragment_size: 0,
          number_of_fragments: 0
        }
      end

      def build
        {
          size: MAX_RESULTS,

          query: {
            function_score: {
              query: { 
                bool: { 
                  should: @match_clauses
                }
              },

              field_value_factor: {
                field: 'priority',
                modifier: 'log1p',
                factor: 2
              }
            }
          },

          highlight: {
            pre_tags: [HIGHLIGHT_START_TAG],
            post_tags: [HIGHLIGHT_END_TAG],
            fields: @highlight_clauses
          }
        }
      end
    end

    private_constant :SearchBodyBuilder
end
