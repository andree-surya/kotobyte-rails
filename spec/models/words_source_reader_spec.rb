require 'rails_helper'

describe WordsSourceReader do

  it 'should parse test data without error' do
    words = WordsSourceReader.new.read_all

    expect(words.count).to eq(5)

    words.each do |word|
      expect(word.id).to be_present
      expect(word.literals).to be_present
    end
  end

  it 'should parse word ID' do

    id = 1234

    xml = "<entry><ent_seq>#{id}</ent_seq></entry>"
    word = WordsSourceReader.new(source_xml: xml).read_one

    expect(word.id).to eq(id)
  end

  it 'should parse word priority' do

    xml = <<-EOS.strip_heredoc
      <JMdict>
        <entry>
          <k_ele>
            <ke_pri>ichi2</ke_pri>
            <ke_pri>news1</ke_pri>
            <ke_pri>nf12</ke_pri>
          </k_ele>
        </entry>
        <entry>
          <r_ele>
            <re_pri>gai2</re_pri>
            <re_pri>news2</re_pri>
            <re_pri>nf45</re_pri>
          </r_ele>
        </entry>
        <entry>
          <k_ele></k_ele>
          <r_ele></r_ele>
        </entry>
      </JMdict>
    EOS

    words = WordsSourceReader.new(source_xml: xml).read_all

    expect(words[0].priority).to eq(1 + 16 + 32)
    expect(words[1].priority).to eq(1 + 16 + 16)
    expect(words[2].priority).to eq(1)
  end

  it 'should parse literal elements' do

    xml = <<-EOS.strip_heredoc
      <!DOCTYPE JMdict [
        <!ENTITY iK "Irregular Kanji">
        <!ENTITY io "Irregular Okurigana">
        <!ENTITY oK "Outdated Kanji">
      ]>

      <JMdict>
        <entry>
          <k_ele><keb>冗談</keb></k_ele>
          <k_ele><keb>言葉</keb><ke_pri>news2</ke_pri></k_ele>
          <k_ele><keb>匂い</keb><ke_inf>&iK;</ke_inf></k_ele>
          <k_ele><keb>お茶</keb><ke_inf>&io;</ke_inf></k_ele>
          <k_ele><keb>電車</keb><ke_inf>&oK;</ke_inf></k_ele>
        </entry>
      </JMdict>
    EOS

    literals = WordsSourceReader.new(source_xml: xml).read_one.literals

    expect(literals.size).to eq(5)
    expect(literals[0].text).to eq('冗談')
    expect(literals[1].text).to eq('言葉')
    expect(literals[2].text).to eq('匂い')
    expect(literals[3].text).to eq('お茶')
    expect(literals[4].text).to eq('電車')

    expect(literals[1]).to be_common
    expect(literals[2]).to be_irregular
    expect(literals[3]).to be_irregular
    expect(literals[4]).to be_outdated
  end

  it 'should parse reading elements' do

    xml = <<-EOS.strip_heredoc
      <!DOCTYPE JMdict [
        <!ENTITY ik "Irregular Kana">
        <!ENTITY ok "Outdated Kana">
      ]>

      <JMdict>
        <entry>
          <r_ele><reb>ことば</reb></r_ele>
          <r_ele><reb>じょうだん</reb><re_pri>ichi1</re_pri></r_ele>
          <r_ele><reb>におい</reb><re_inf>&ik;</re_inf></r_ele>
          <r_ele><reb>おちゃ</reb><re_inf>&ok;</re_inf></r_ele>
        </entry>
      </JMdict>
    EOS

    readings = WordsSourceReader.new(source_xml: xml).read_one.readings

    expect(readings.size).to eq(4)
    expect(readings[0].text).to eq('ことば')
    expect(readings[1].text).to eq('じょうだん')
    expect(readings[2].text).to eq('におい')
    expect(readings[3].text).to eq('おちゃ')

    expect(readings[1]).to be_common
    expect(readings[2]).to be_irregular
    expect(readings[3]).to be_outdated
  end

  it 'should parse sense and translation texts' do

    xml = <<-EOS.strip_heredoc
      <entry>
        <sense>
          <gloss>declaration</gloss>
          <gloss>hearsay</gloss>
        </sense>
        <sense>
          <gloss>conduct</gloss>
        </sense>
        <trans>
          <trans_det>African National Congress</trans_det>
          <trans_det>ANC</trans_det>
        </trans>
      </entry>
    EOS

    senses = WordsSourceReader.new(source_xml: xml).read_one.senses

    expect(senses.size).to eq(3)
    expect(senses[0].text).to eq('declaration; hearsay')
    expect(senses[1].text).to eq('conduct')
    expect(senses[2].text).to eq('African National Congress; ANC')
  end

  it 'should parse sense categories' do

    xml = <<-EOS.strip_heredoc
      <!DOCTYPE JMdict [
        <!ENTITY n "noun (common) (futsuumeishi)">
        <!ENTITY adj-i "adjective (keiyoushi)">
        <!ENTITY v5u "godan verb with 'u' ending">
      ]>

      <JMdict>
        <entry>
          <sense>
            <pos>&n;</pos>
            <pos>&adj-i;</pos>
          </sense>
          <sense>
          </sense>
          <sense>
            <pos>&v5u;</pos>
          </sense>
        </entry>
      </JMdict>
    EOS

    senses = WordsSourceReader.new(source_xml: xml).read_one.senses

    expect(senses.size).to eq(3)
    expect(senses[0].categories).to eq(['n', 'adj-i'])
    expect(senses[1].categories).to eq(['n', 'adj-i'])
    expect(senses[2].categories).to eq(['v5u'])
  end

  it 'should parse sense sources' do

    xml = <<-EOS.strip_heredoc
      <entry>
        <sense>
          <lsource xml:lang="ger">Abend</lsource>
          <lsource xml:lang="kor" />
        </sense>
        <sense>
          <lsource>Ice</lsource>
        </sense>
      </entry>
    EOS

    senses = WordsSourceReader.new(source_xml: xml).read_one.senses

    expect(senses.size).to eq(2)
    expect(senses[0].sources).to eq(['ger:Abend', 'kor'])
    expect(senses[1].sources).to eq(['eng:Ice'])
  end

  it 'should parse sense labels' do

    xml = <<-EOS.strip_heredoc
      <!DOCTYPE JMdict [
        <!ENTITY comp "computer terminology">
        <!ENTITY col "colloquialism">
        <!ENTITY on-mim "onomatopoeic">
        <!ENTITY ksb "Kansai-ben">
        <!ENTITY uK "word usually written using Kanji alone">
      ]>

      <JMdict>
        <entry>
          <sense>
            <field>&comp;</field>
            <misc>&col;</misc>
            <misc>&on-mim;</misc>
          </sense>
          <sense>
            <dial>&ksb;</dial>
            <misc>&uK;</misc>
          </sense>
        </entry>
      </JMdict>
    EOS

    senses = WordsSourceReader.new(source_xml: xml).read_one.senses

    expect(senses.size).to eq(2)
    expect(senses[0].labels).to eq(['comp', 'col', 'on-mim'])
    expect(senses[1].labels).to eq(['ksb', 'uK'])
  end

  it 'should parse sense notes' do

    xml = <<-EOS.strip_heredoc
      <entry>
        <sense>
          <s_inf>A</s_inf>
        </sense>
        <sense>
          <s_inf>B</s_inf>
          <s_inf>C</s_inf>
        </sense>
      </entry>
    EOS

    senses = WordsSourceReader.new(source_xml: xml).read_one.senses

    expect(senses.size).to eq(2)
    expect(senses[0].notes).to eq(['A'])
    expect(senses[1].notes).to eq(['B', 'C'])
  end

  it 'should assign noun category for translation' do

    xml = <<-EOS.strip_heredoc
      <JMdict>
        <entry>
          <trans>
            <trans_det>Shinagawa</trans_det>
          </trans>
        </entry>
      </JMdict>
    EOS

    senses = WordsSourceReader.new(source_xml: xml).read_one.senses
    expect(senses[0].categories).to eq(['n'])
  end

  it 'should parse translation types' do

    xml = <<-EOS.strip_heredoc
      <!DOCTYPE JMdict [
        <!ENTITY surname "family or surname">
        <!ENTITY place "place name">
        <!ENTITY unclass "unclassified name">
      ]>

      <JMdict>
        <entry>
          <trans>
            <name_type>&surname;</name_type>
            <name_type>&place;</name_type>
          </trans>
          <trans>
            <name_type>&unclass;</name_type>
          </trans>
          <trans>
          </trans>
        </entry>
      </JMdict>
    EOS

    senses = WordsSourceReader.new(source_xml: xml).read_one.senses

    expect(senses.size).to eq(3)
    expect(senses[0].labels).to eq(['surname', 'place'])
    expect(senses[1].labels).to eq([])
    expect(senses[2].labels).to eq([])
  end
end
