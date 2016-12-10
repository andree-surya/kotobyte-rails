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

    markup.gsub!(WordsRepository::HIGHLIGHT_START_TAG, '<mark>')
    markup.gsub!(WordsRepository::HIGHLIGHT_END_TAG, '</mark>')

    raw markup
  end

  def remove_highlight(text)
    sanitized_text = text.dup

    sanitized_text.gsub!(WordsRepository::HIGHLIGHT_START_TAG, '')
    sanitized_text.gsub!(WordsRepository::HIGHLIGHT_END_TAG, '')

    sanitized_text
  end

  def word_literals_text(word)
    strings = []

    word.literals.each do |literal|

      text = ''
      status = literal.status

      literal.text.split('').each do |character|

        if character.kanji?
          text << kanji_link(character)
        else
          text << character
        end
      end

      text = markup_highlight(text)

      strings << content_tag(:span, text, class: status)
    end

    strings.join('、 ')
  end

  def word_readings_text(word)
    strings = []

    word.readings.each do |reading|
      status = reading.status
      text = markup_highlight(reading.text)
      romaji = remove_highlight(reading.text).romaji

      strings << content_tag(:ruby) do
        concat content_tag(:rb, text, class: status)
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

  def sense_extras_text(sense)
    labels = []

    labels += sense.labels.map { |code| t("labels.#{code}") }
    labels += sense.notes.map { |note| note.upcase_first }

    labels += sense.sources.map do |source|
      code, text = source.split(':')
      language_name = t("iso_639_2.#{code}", default: 'Unknown')

      source_label = "From #{language_name}"
      source_label += " \"#{text}\"" if text.present?

      source_label
    end

    if labels.present?
      'ー' + labels.join('. ')
    else
      ''
    end
  end

  def search_link(query)
    link_to query, search_path(query: query)
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

  def reminder_link(word)

    data = { 'popup-trigger' => 'click' }

    if signed_in?
      data['popup-id'] = "popup-reminder-#{word.id}"
      data['popup-src'] = ''
    else
      data['popup-id'] = 'popup-sign-in'
      data['popup-text'] = render(partial: 'sign_in')
    end

    link_to '', 'javascript:', class: 'reminder-link', data: data
  end
end
