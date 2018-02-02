
class SentencesSourceReader

  STOP_WORDS = 'へ|か|が|の|に|と|で|や|も|わ|は|さ|よ|ね|を'

  def initialize(source_csv: '', indices_csv: '')
    @source_csv = source_csv
    @indices_csv = indices_csv
  end

  def read_one
    read_all.first
  end

  def read_all
    sentences = []
    raw_texts = {}

    @source_csv.each_line do |row|
      columns = row.split("\t")
      language = columns[1]

      raw_texts[columns[0].to_i] = columns[2]
    end

    @indices_csv.each_line do |row|
      columns = row.split("\t")

      original_id = columns[0].to_i
      translation_id = columns[1].to_i

      original_text = raw_texts[original_id]&.strip
      translated_text = raw_texts[translation_id]&.strip
      tokens_pattern = columns[2]
      
      next if original_text.nil? || translated_text.nil?

      sentences << Sentence.new(
        id: original_id,
        tokenized: tokenize(original_text, tokens_pattern),
        translated: translated_text 
      )
    end

    sentences
  end

  private

    def tokenize(text, tokens_pattern)

      tokens_pattern.gsub!(/\|[[:digit:]]+/, '') # Remove number markers |1 in は|1
      tokens_pattern.gsub!(/\[[[:digit:]]+\]/, '') # Remove number markers [01] in から[01]
      tokens_pattern.gsub!(/\([[:word:]]+\)/, '') # Remove reading markers (かれら) in 彼ら(かれら)
      tokens_pattern.gsub!('~', '')

      offset = 0

      tokens_pattern.split.each do |raw_token|

        token_variations = [
          raw_token[/{(.+)}/, 1], # Match original form した in 為る{した}
          raw_token[/([^{]+)/, 1] # Match lemma form 為る in 為る{した}
          
        ].compact

        representative_token = token_variations.first

        start_index = text.index(representative_token, offset)

        if start_index.present?
          
          token_replacement = " #{token_variations.join('|')} "
          end_index = start_index + representative_token.length

          text[start_index...end_index] = token_replacement

          offset += token_replacement.length
        end
      end

      text.strip!
      text.squeeze!(' ')

      text
    end
end
