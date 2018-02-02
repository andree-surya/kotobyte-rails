
class SentencesSourceReader

  STOP_WORDS = 'へ|か|が|の|に|と|で|や|も|わ|は|さ|よ|ね|を|「|」|！|。|、'

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
      
      next if original_text.nil? || translated_text.nil?

      sentences << Sentence.new(
        id: original_id,
        original: original_text,
        tokenized: tokenize(columns[2]),
        translated: translated_text 
      )
    end

    sentences
  end

  private

    def tokenize(tokens_pattern)

      tokens_pattern.gsub!(/\|[[:digit:]]+/, '') # Remove number markers |1 in は|1
      tokens_pattern.gsub!(/\[[[:digit:]]+\]/, '') # Remove number markers [01] in から[01]
      tokens_pattern.gsub!(/\([[:word:]]+\)/, '') # Remove reading markers (かれら) in 彼ら(かれら)
      tokens_pattern.gsub!(/\b[#{STOP_WORDS}]\b/, '') # Remove punctuations and stop words
      tokens_pattern.gsub!('~', '')

      tokens = tokens_pattern.split.map do |raw_token|

        lemma_form = raw_token[/([^{]+)/, 1] # Match 為る in 為る{した}
        original_form = raw_token[/{(.+)}/, 1] # Match した in 為る{した}
        
        if original_form.present?
          "#{original_form}|#{lemma_form}"
        else
          lemma_form
        end        
      end

      tokens.join(' ')
    end
end
