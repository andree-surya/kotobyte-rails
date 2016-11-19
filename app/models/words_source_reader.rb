
class WordsSourceReader

  PRIORITY_PREFIXES = ['ichi', 'news', 'spec', 'gai']

  def initialize(
      source_xml: IO.read(Rails.configuration.app[:words_source_file]))

    @xml = source_xml
  end

  def read_one
    read_all.first
  end

  def read_all
    words = []

    read_each do |word|
      words << word
    end

    words
  end

  def read_each(&word_handler)

    Nokogiri::XML::Reader(@xml).each do |node|
      is_start_element = node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
      is_end_element = node.node_type == Nokogiri::XML::Reader::TYPE_END_ELEMENT

      if is_start_element
        handle_start_element(node)

      elsif is_end_element
        handle_end_element(node, &word_handler)
      end
    end
  end

  private

    def handle_start_element(node)

      case node.name
      when 'entry'
        @current_word = Word.new

      when 'ent_seq'
        @current_word.id = node.inner_xml.to_i

      when 'k_ele'
        @current_word.literals << Literal.new

      when 'r_ele'
        @current_word.readings << Literal.new

      when 'keb'
        literal = @current_word.literals.last
        literal.text = node.inner_xml

      when 'reb'
        reading = @current_word.readings.last
        reading.text = node.inner_xml

      when 'ke_pri'
        literal = @current_word.literals.last
        literal.status = :common

        process_priority(node.inner_xml)

      when 're_pri'
        reading = @current_word.readings.last
        reading.status = :common

        process_priority(node.inner_xml)

      when 'ke_inf'
        literal = @current_word.literals.last

        case clean_xml_entity(node.inner_xml)
        when 'iK', 'io'
          literal.status = :irregular

        when 'oK'
          literal.status = :outdated
        end

      when 're_inf'
        reading = @current_word.readings.last

        case clean_xml_entity(node.inner_xml)
        when 'ik'
          reading.status = :irregular

        when 'ok'
          reading.status = :outdated
        end

      when 'sense'
        @current_word.senses << Sense.new

      when 'trans'
        @current_word.senses << Sense.new
        @current_word.senses.last.categories << 'n'

      when 'pos'
        sense = @current_word.senses.last
        sense.categories << clean_xml_entity(node.inner_xml)

      when 'field', 'dial', 'misc', 'name_type'
        sense = @current_word.senses.last
        entity = clean_xml_entity(node.inner_xml)

        sense.labels << entity unless entity == 'unclass'

      when 's_inf'
        sense = @current_word.senses.last
        sense.notes << node.inner_xml

      when 'lsource'
        sense = @current_word.senses.last

        source = node.attributes['lang'] || 'eng'
        source += ":#{node.inner_xml}" if node.inner_xml.present?

        sense.sources << source

      when 'gloss', 'trans_det'
        sense = @current_word.senses.last
        sense.text += '; ' if sense.text.present?
        sense.text += node.inner_xml
      end
    end

    def handle_end_element(node, &word_handler)

      case node.name
      when 'entry'
        yield @current_word
        @current_word = nil

      when 'sense'
        current_sense = @current_word.senses[-1]
        preceeding_sense = @current_word.senses[-2]

        if current_sense.categories.empty? && preceeding_sense.present?
          current_sense.categories = preceeding_sense.categories
        end
      end
    end

    def clean_xml_entity(text)
      text.tr('\&\;', '')
    end

    def process_priority(text)

      PRIORITY_PREFIXES.each do |prefix|

        if text.start_with? prefix
          priority_class = text.sub(prefix, '').to_i
          priority_score = priority_class == 1 ? 32 : 16

          @current_word.priority += priority_score
        end
      end
    end
end
