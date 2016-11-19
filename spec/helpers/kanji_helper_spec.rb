require 'rails_helper'

describe KanjiHelper, :type => :helper do
  
  describe '#kanji_literal_text' do
    let(:kanji) { Kanji.new({ 'literal' => '試' }) }

    it 'should contain literal text' do
      text = kanji_literal_text(kanji)

      expect(text).to include(kanji.literal)
    end

    it 'should assign common class for common kanji' do
      kanji.grade = 1
      text = kanji_literal_text(kanji)
      
      expect(kanji).to be_common
      expect(text).to include('common')
    end

    it 'should not assign common class for uncommon kanji' do
      kanji.grade = nil
      text = kanji_literal_text(kanji)

      expect(kanji).not_to be_common
      expect(text).not_to include('common')
    end
  end

  describe '#kanji_meanings_text' do
    let(:kanji) do
      kanji = Kanji.new
      kanji.meanings << 'audacious'
      kanji.meanings << 'fearless'

      kanji
    end

    it 'should contain all meanings text' do
      text = kanji_meanings_text(kanji)

      kanji.meanings.each do |meaning|
        expect(text).to include(meaning)
      end
    end

    it 'should emphasize only the first meaning' do
      text = kanji_meanings_text(kanji)

      expect(text).to match(/<em>#{kanji.meanings[0]}<\/em>/)
      expect(text).not_to match(/<em>#{kanji.meanings[1]}<\/em>/)
    end
  end

  describe '#kanji_readings_text' do
    let(:kanji) do
      kanji = Kanji.new
      kanji.readings << 'アナ'
      kanji.readings << 'はなの'

      kanji
    end

    it 'should contain all readings text' do
      text = kanji_readings_text(kanji)

      kanji.readings.each do |reading|
        expect(text).to include(reading)
      end
    end

    it 'should contain all readings in Romaji' do
      text = kanji_readings_text(kanji)

      kanji.readings.each do |reading|
        expect(text).to include(reading.romaji)
      end
    end
  end

  describe '#kanji_extras_text' do
    let (:kanji) { Kanji.new }

    it 'should include JLPT information if available' do
      text = kanji_extras_text(kanji)
      expect(text).not_to include('JLPT')

      kanji.jlpt = 2
      text = kanji_extras_text(kanji)
      expect(text).to include('JLPT')
    end

    it 'should include grade information if available' do
      text = kanji_extras_text(kanji)
      expect(text).not_to include('grade')

      kanji.grade = 1
      text = kanji_extras_text(kanji)
      expect(text).to include('grade')
    end
  end

  describe '#kanji_strokes_svg' do
    it 'should draw strokes up to the specified count' do
      
      kanji = Kanji.new({ 'strokes' => [] })
      kanji.strokes << 'M33.99,15.39c0.14,1.18,0.24,2.67-0.12,4.12'
      kanji.strokes << 'M64.31,13.52c0.96,0.43,2.32,2.53,2.3,3.76'
      kanji.strokes << 'M42.46,29.75c0,3.93-2.06,12.02-3.25,14.64'

      1.upto(kanji.strokes.count) do |count|
        svg = kanji_strokes_svg(kanji, upto_strokes_count: count)
        doc = Nokogiri::XML(svg)

        expect(doc.xpath('//line').count).to eq(2)
        expect(doc.xpath('//circle').count).to eq(1)
        expect(doc.xpath('//path').count).to eq(count)
        expect(doc.xpath('//path[@class="current"]').count).to eq(1)
      end
    end
  end
end
