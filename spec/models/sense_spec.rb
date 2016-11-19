
describe Sense do

  describe '#initialize' do
    context 'when called without parameters' do
      let(:sense) { Sense.new }

      it 'should have empty text' do
        expect(sense.text).to be_empty
      end

      it 'should have empty categories' do
        expect(sense.categories).to be_empty
      end

      it 'should have empty sources' do
        expect(sense.sources).to be_empty
      end

      it 'should have empty labels' do
        expect(sense.labels).to be_empty
      end

      it 'should have empty notes' do
        expect(sense.notes).to be_empty
      end
    end

    context 'when called with attributes parameters' do

      let(:attributes) do
        {
          'text' => 'word; vocabulary',
          'categories' => ['n', 'adj-i'],
          'labels' => ['uk', 'derog'],
          'notes' => ['sometimes written 居らっしゃる'],
          'sources' => ['deu:Arbeit', 'dut:Glas']
        }
      end

      let(:sense) { Sense.new(attributes) }

      it 'should set text' do
        expect(sense.text).to eq(attributes['text'])
      end

      it 'should set categories' do
        expect(sense.categories).to eq(attributes['categories'])
      end

      it 'should set sources' do
        expect(sense.sources).to eq(attributes['sources'])
      end

      it 'should set labels' do
        expect(sense.labels).to eq(attributes['labels'])
      end

      it 'should set notes' do
        expect(sense.notes).to eq(attributes['notes'])
      end
    end
  end
end
