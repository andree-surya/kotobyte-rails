module WordsHelper

  def search_results_summary_text(search_results)
    count = search_results.count

    if count > 0
      time = search_results.response['took'] / 1000.0

      if search_results.total > count
        message = t('showing_top_results', count: count)
      else
        message = t('found_search_results', count: count)
      end

      return message + " (#{time} seconds)"
    else
      return t('no_search_results')
    end
  end

  def markup_highlight(text)
    markup = text.dup

    markup.gsub!('{', '<mark>')
    markup.gsub!('}', '</mark>')

    raw markup
  end

  def remove_highlight(text)
    sanitized_text = text.dup

    sanitized_text.gsub!('{', '')
    sanitized_text.gsub!('}', '')

    sanitized_text
  end

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

  def sense_categories_text(sense)
    category_texts = []

    sense.categories.each do |category|

      options = {
        data: {
          'popup-id' => "popup-category-#{category}",
          'popup-text' => t("labels.#{category}"),
          'popup-trigger' => 'hover',
        }
      }

      category_texts << link_to(category, 'javascript:', options)
    end

    category_texts.join(', ')
  end

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

  def sense_extras_text(sense)
    extras = sense_extras(sense)
    
    if extras.present?
      'ー' + extras.join('. ')
    else
      ''
    end
  end

  def search_link(query)
    link_to query, search_words_path(query: query)
  end

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
  
    def priority_class(priority)

      return 'irregular' if priority < 0
      return 'common' if priority > 0

      return nil
    end
end
