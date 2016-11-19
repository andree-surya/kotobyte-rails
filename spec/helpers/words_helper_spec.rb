require 'rails_helper'

describe WordsHelper, type: :helper do

  describe '#search_results_summary_text' do

    context 'when we got no search results' do
      it 'should return a message of apology' do

        results = double('search_results')
        expect(results).to receive(:count).and_return(0)

        string = search_results_summary_text(results)
        expect(string).to include('Sorry')
      end
    end

    context 'when there are 1 or more search results' do

      it 'should include a match count information' do
        count = 38
        results = double('search_results')

        expect(results).to receive(:count).and_return(count)
        expect(results).to receive(:total).and_return(100)
        expect(results).to receive(:response).and_return({ 'took' => 100 })

        string = search_results_summary_text(results)
        expect(string).to include("#{count}")
      end
    end
  end

  describe '#markup_highlight' do
    it 'should replace highlight tags with markup' do

      markup = markup_highlight('one {two} three')
      expect(markup).to eq('one <mark>two</mark> three')
    end
  end

  describe '#remove_highlight' do
    it 'should remove highlight tags' do

      text = remove_highlight('one {two} three')
      expect(text).to eq('one two three')
    end
  end

  describe '#word_literals_text' do
    let(:word) do
      word = Word.new
      word.literals << Literal.new({ 'text' => '食べる' })
      word.literals << Literal.new({ 'text' => 'お花見' })

      word
    end

    it 'should tag Kanji characters with link' do
      string = word_literals_text(word)

      expect(string).to match(/<a.*>食<\/a>べる/)
      expect(string).to match(/お<a.*>花<\/a><a.*>見<\/a>/)
    end

    it 'should include literal status' do
      word.literals.first.status = 'irregular'

      string = word_literals_text(word)
      expect(string).to include('irregular')
    end
  end

  describe '#word_readings_text' do
    let(:word) do
      word = Word.new
      word.readings << Literal.new({ 'text' => 'ことば' })
      word.readings << Literal.new({ 'text' => 'げんご' })

      word
    end

    it 'should list up all texts with Romaji readings' do
      string = word_readings_text(word)

      word.readings.each do |reading|
        expect(string).to include(reading.text)
        expect(string).to include(reading.text.romaji)
      end
    end

    it 'should include reading status' do
      word.readings.first.status = 'common'

      string = word_readings_text(word)
      expect(string).to include('common')
    end
  end

  describe '#sense_categories_text' do
    it 'should return lexical categories for each sense' do
      sense = Sense.new({ 'categories' => ['n', 'adj-i', 'adv'] })
      string = sense_categories_text(sense)

      sense.categories.each do |category|
        expect(string).to include(category)
        expect(string).to include(t("labels.#{category}"))
      end
    end
  end

  describe '#sense_extras_text' do
    before(:each) do
      sense = Sense.new
      sense.labels = ['abbr', 'uk']
      sense.notes = ['note 1', 'note 2']
      sense.sources = ['eng', 'ger:Eis', 'unk']

      @extras_text = sense_extras_text(sense)
    end

    it 'should include labels info' do
      expect(@extras_text).to include('Abbreviation', 'Kana')
    end

    it 'should include sources info' do
      expect(@extras_text).to include('English', 'German', 'Eis', 'Unknown')
    end

    it 'should include notes info' do
      expect(@extras_text).to include('Note 1', 'Note 2')
    end
  end

  describe '#search_link' do
    let(:query) { '自由' }
    let(:link) { search_link(query) }

    it 'should encapsulate search query in HTML link tag' do
      expect(link).to match(/<a.*>#{query}<\/a>/)
    end

    it 'should include link path' do
      expect(link).to include(search_path(query: query))
    end
  end

  describe '#kanji_link' do
    let(:literal) { '漢' }
    let(:link) { kanji_link(literal) }

    it 'should encapsulate character in HTML link tag' do
      expect(link).to match(/<a.*>#{literal}<\/a>/)
    end

    it 'should include link path' do
      expect(link).to include(kanji_path(literal))
    end
  end
end
