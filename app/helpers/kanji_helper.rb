
module KanjiHelper

  #
  # @param [<Kanji>]
  # @return [<String>] Kanji character HTML text
  #
  # @todo Factor-out common Kanji determination logic
  #
  def kanji_character_text(kanji)
    tag_classes = []
    
    if kanji.jlpt&.between?(1, 4) || kanji.grade&.between?(1, 6) || kanji.grade == 8
      tag_classes << 'common'
    end

    content_tag :span, kanji.character, class: tag_classes
  end

  #
  # @param [<Kanji>]
  # @return [<String>] Kanji meanings HTML text
  #
  def kanji_meanings_text(kanji)
    meanings = kanji.meanings.to_a

    meanings[0] = content_tag :em, meanings[0]

    meanings.join(', ')
  end

  #
  # @param [<Kanji>]
  # @return [<String>] Kanji readings HTML text
  #
  def kanji_readings_text(kanji)
    readings_text = []

    kanji.readings.each do |reading|
      
      readings_text << content_tag(:ruby) do
        concat content_tag(:rb, reading)
        concat content_tag(:rp, '/')
        concat content_tag(:rt, reading.romaji)
        concat content_tag(:rp, '/')
      end
    end

    readings_text.join('、 ')
  end

  #
  # @param [<Kanji>]
  # @return [<String>] Kanji extra info HTML text
  #
  def kanji_extras_text(kanji)

    metadata_text = kanji_extras(kanji).compact.join(', ')
    metadata_text = 'ー' + metadata_text if metadata_text.present? 

    metadata_text
  end

  #
  # @param [<Kanji>]
  # @param [<Integer>] upto_strokes_count Display only up to a certain number of strokes
  # @return [<String>] Kanji strokes SVG display
  #
  def kanji_strokes_svg(kanji, upto_strokes_count:)

    strokes = kanji.strokes[0...upto_strokes_count]

    marker_location = /^M\s*([\d\.]+)\s*,\s*([\d\.]+)/.match(strokes.last)
    raise "Invalid path: #{strokes.last}" if marker_location.nil?

    marker_cx = marker_location[1].to_f
    marker_cy = marker_location[2].to_f

    content_tag(:svg, viewBox: '0 0 109 109') do
    
      strokes.each_with_index do |stroke, index| 
        options = { d: stroke }

        if index == strokes.count - 1
          options[:class] = 'current' 
        end

        concat tag(:path, options)
      end

      concat tag(:line, x1: 54, y1: 0, x2: 54, y2: 109)
      concat tag(:line, x1: 0, y1: 54, x2: 109, y2: 54)
      concat tag(:circle, cx: marker_cx, cy: marker_cy, r: 5)
    end
  end

  private
    def kanji_extras(kanji)
      jlpt_label = t("kanji.jlpt_#{kanji.jlpt}", default: '')
      grade_label = t("kanji.grade_#{kanji.grade}", default: '')

      metadata_labels = []
      
      metadata_labels << jlpt_label if jlpt_label.present?
      metadata_labels << grade_label if grade_label.present?

      metadata_labels
    end
end
