module WordsHelper

  #
  # Transform highlighted texts to HTML text
  # e.g. 環境{悪化} -> 環境<mark>悪化</mark>
  #
  # @return [<String>]
  #
  def markup_highlight(text)
    markup = text.dup

    markup.gsub!('{', '<mark>')
    markup.gsub!('}', '</mark>')

    raw markup
  end

  #
  # Remove highlighted texts
  # e.g. 環境{悪化} -> 環境悪化
  #
  # @return [<String>]
  #
  def remove_highlight(text)
    sanitized_text = text.dup

    sanitized_text.gsub!('{', '')
    sanitized_text.gsub!('}', '')

    sanitized_text
  end

  #
  # @param [<Word>]
  # @return [<String>] Word literals HTML text
  #
  def word_literals_text(word)
    strings = []

    word.literals.each do |literal|

      text = ''

      literal.text.split('').each do |character|

        if character.kanji?
          text << kanji_link(character)
        else
          text << character
        end
      end

      text = markup_highlight(text)

      strings << content_tag(:span, text, class: priority_class(literal.priority))
    end

    strings.join('、 ')
  end

  #
  # @param [<Word>]
  # @return [<String>] Word readings HTML text
  #
  def word_readings_text(word)
    strings = []

    word.readings.each do |reading|

      text = markup_highlight(reading.text)
      romaji = remove_highlight(reading.text).romaji

      strings << content_tag(:ruby) do
        concat content_tag(:rb, text, class: priority_class(reading.priority))
        concat content_tag(:rp, '/')
        concat content_tag(:rt, romaji)
        concat content_tag(:rp, '/')
      end
    end

    strings.join('、 ')
  end

  #
  # @param [<Sense>]
  # @return [<String>] Word sense categories HTML text
  #
  def sense_categories_text(sense)
    category_texts = []

    sense.categories.each do |category|

      options = {
        data: {
          'popup-id' => "popup-category-#{category}",
          'popup-text' => t("labels.#{category}").upcase_first,
          'popup-trigger' => 'hover',
        }
      }

      category_texts << link_to(category, 'javascript:', options)
    end

    category_texts.join(', ')
  end

  #
  # @param [<Sense>]
  # @return [<String>] Word sense extra info HTML text
  #
  def sense_extras_text(sense)
    extras = sense_extras(sense)
    
    if extras.present?
      'ー' + extras.join(', ')
    else
      ''
    end
  end

  #
  # @param [<String>]
  # @return [<String>] Search link for the given query
  #
  def search_link(query)
    link_to query, search_words_path(query: query)
  end

  #
  # @param [<Sense>]
  # @return [<String>] Kanji display link for the given literal
  #
  def kanji_link(literal)
    
    options = {
      class: 'kanji',
      
      data: {
        'popup-id' => "popup-kanji-#{literal}",
        'popup-src' => kanji_path(literal: literal),
        'popup-trigger' => 'click'
      }
    }

    link_to(literal, 'javascript:', options)
  end

  private

    def sense_extras(sense)
      extras = []

      extras += sense.labels.map { |code| t("labels.#{code}").upcase_first }
      extras += sense.notes.map { |note| note.upcase_first }

      extras += sense.origins.map do |origin|
        language_name = t("languages.#{origin.lang}", default: 'Unknown')

        origin_label = "From #{language_name}"
        origin_label += " \"#{origin.text}\"" if origin.text.present?

        origin_label
      end

      extras
    end
  
    def priority_class(priority)

      return 'irregular' if priority < 0
      return 'common' if priority > 0

      return nil
    end
end
