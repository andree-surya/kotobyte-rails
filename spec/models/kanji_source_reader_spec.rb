
describe KanjiSourceReader do

  it 'should parse test data without error' do
    kanji_list = KanjiSourceReader.new.read_all

    expect(kanji_list.count).to eq(5)

    kanji_list.each do |kanji|
      expect(kanji.id).to be_present
      expect(kanji.strokes).to be_present
    end
  end

  it 'should parse UCS code point as ID' do
    ID = '4e9c'

    xml = <<-EOS.strip_heredoc
      <character>
        <codepoint>
          <cp_value cp_type="jis208">16-01</cp_value>
          <cp_value cp_type="ucs">#{ID}</cp_value>
        </codepoint>
      </character>
    EOS

    reader = KanjiSourceReader.new(source_xml: xml)
    expect(reader.read_one.id).to eq(ID.to_i(16))
  end

  it 'should parse literal' do
    xml = '<character><literal>豚</literal></character>'

    reader = KanjiSourceReader.new(source_xml: xml)
    expect(reader.read_one.literal).to eq('豚')
  end

  it 'should parse grade' do
    xml = '<character><misc><grade>5</grade></misc></character>'

    reader = KanjiSourceReader.new(source_xml: xml)
    expect(reader.read_one.grade).to eq(5)
  end

  it 'should parse JLPT' do
    xml = '<character><misc><jlpt>3</jlpt></misc></character>'

    reader = KanjiSourceReader.new(source_xml: xml)
    expect(reader.read_one.jlpt).to eq(3)
  end

  it 'should parse on and kun readings' do
    xml = <<-EOS.strip_heredoc
      <character>
        <reading_meaning>
          <rmgroup>
            <reading r_type="pinyin">ya1</reading>
            <reading r_type="ja_on">ア</reading>
          </rmgroup>
          <rmgroup>
            <reading r_type="korean_h">아</reading>
            <reading r_type="ja_on">アク</reading>
            <reading r_type="ja_kun">おし</reading>
            <reading r_type="ja_kun">を</reading>
          </rmgroup>
        </reading_meaning>
      </character>
    EOS


    kanji = KanjiSourceReader.new(source_xml: xml).read_one

    expect(kanji.readings.count).to eq(4)
    expect(kanji.readings[0]).to eq('ア')
    expect(kanji.readings[1]).to eq('アク')
    expect(kanji.readings[2]).to eq('おし')
    expect(kanji.readings[3]).to eq('を')
  end

  it 'should parse meanings' do
    xml = <<-EOS.strip_heredoc
      <character>
        <reading_meaning>
          <rmgroup>
            <meaning>mute</meaning>
            <meaning>dumb</meaning>
          </rmgroup>
          <rmgroup>
            <meaning>silence</meaning>
          </rmgroup>
        </reading_meaning>
      </character>
    EOS

    kanji = KanjiSourceReader.new(source_xml: xml).read_one

    expect(kanji.meanings.count).to eq(3)
    expect(kanji.meanings[0]).to eq('mute')
    expect(kanji.meanings[1]).to eq('dumb')
    expect(kanji.meanings[2]).to eq('silence')
  end

  it 'should parse strokes' do

    kanji_id_hex = '045ce'
    kanji_id = kanji_id_hex.to_i(16)
    strokes = ['M15.88,89.23c3', 'M42.12,24c1.09']

    source_xml = <<-EOS.strip_heredoc
      <character>
        <codepoint>
          <cp_value cp_type="ucs">#{kanji_id_hex}</cp_value>
        </codepoint>
      </character>
    EOS

    strokes_xml = <<-EOS.strip_heredoc
      <kanji id="kvg:kanji_#{kanji_id_hex}">
        <path d="#{strokes[0]}"/>
        <path d="#{strokes[1]}"/>
      </kanji>
    EOS

    reader = KanjiSourceReader.new(
        source_xml: source_xml,
        strokes_xml: strokes_xml
    )

    expect(reader.read_one.strokes).to eq(strokes)
  end
end
