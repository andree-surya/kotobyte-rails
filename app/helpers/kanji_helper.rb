
module KanjiHelper

  @@common_grades = [
    :GRADE_JOUYOU_1,
    :GRADE_JOUYOU_2,
    :GRADE_JOUYOU_3,
    :GRADE_JOUYOU_4,
    :GRADE_JOUYOU_5,
    :GRADE_JOUYOU_6
  ]
  
  @@common_jlpt = [
    :JLPT_N1,
    :JLPT_N2_N3,
    :JLPT_N4,
    :JLPT_N5
  ]

  def kanji_character_text(kanji)
    tag_classes = []
    
    if @@common_grades.include?(kanji.grade) || @@common_jlpt.include?(kanji.jlpt)
      tag_classes << 'common'
    end

    content_tag :span, kanji.character, class: tag_classes
  end

  def kanji_meanings_text(kanji)
    meanings = kanji.meanings.to_a

    meanings[0] = content_tag :em, meanings[0]

    meanings.join(', ')
  end

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

  def kanji_extras(kanji)
    jlpt_label = t("kanji.jlpt_#{Kanji::JLPT.resolve kanji.jlpt}", default: '')
    grade_label = t("kanji.grade_#{Kanji::Grade.resolve kanji.grade}", default: '')

    metadata_labels = []
    
    metadata_labels << jlpt_label if jlpt_label.present?
    metadata_labels << grade_label if grade_label.present?

    metadata_labels
  end

  def kanji_extras_text(kanji)

    metadata_text = kanji_extras(kanji).compact.join('. ')
    metadata_text = 'ー' + metadata_text if metadata_text.present? 

    metadata_text
  end

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
end
