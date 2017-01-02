module KanjiHelper 

  def kanji_literal_text(kanji)
    tag_classes = []
    tag_classes << 'common' if kanji.common?

    content_tag :span, kanji.literal, class: tag_classes
  end

  def kanji_meanings_text(kanji)
    meanings = kanji.meanings.clone

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
    metadata_labels = []

    metadata_labels << case kanji.jlpt
    when 1
      'JLPT N1'
    when 2
      'JLPT N2/N3'
    when 3
      'JLPT N4'
    when 4
      'JLPT N5'
    end

    metadata_labels << case kanji.grade
    when 1
      'Elementary school, 1st grade'
    when 2
      'Elementary school, 2nd grade'
    when 3
      'Elementary school, 3rd grade'
    when 4
      'Elementary school, 4th grade'
    when 5
      'Elementary school, 5th grade'
    when 6
      'Elementary school, 6th grade'
    when 8
      'High School grade'
    when 9, 10
      'Jinmeiyou (used in name)'
    end

    metadata_labels
  end

  def kanji_extras_text(kanji)

    metadata_text = kanji_extras(kanji).compact.join('. ')
    metadata_text = 'ー' + metadata_text unless metadata_text.empty?

    metadata_text
  end

  def kanji_strokes_svg(kanji, upto_strokes_count:)

    strokes = kanji.strokes[0...upto_strokes_count]

    marker_location = /^M([\d\.]+),([\d\.]+)/.match(strokes.last)
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
