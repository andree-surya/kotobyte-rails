
describe Word do

  describe '#initialize' do

    context 'when called without JSON parameter' do
      let(:word) { Word.new }

      it 'should not set ID' do
        expect(word.id).to be_nil
      end

      it 'should have no score' do
        expect(word.score).to be_nil
      end

      it 'should default to a priority level of 1' do
        expect(word.priority).to eq(1)
      end
      
      it 'should have empty literals' do
        expect(word.literals).to be_empty
      end

      it 'should have empty readings' do
        expect(word.readings).to be_empty
      end

      it 'should have empty senses' do
        expect(word.senses).to be_empty
      end
    end

    context 'when called with a JSON parameter' do

      let (:attributes) do
        {
          'id' => rand(1..100000).to_s,
          'priority' => 50,

          'literals' => [
            { 'text' => '言葉' },
            { 'text' => '言語' }
          ],
          
          'readings' => [
            { 'text' => 'ことば' },
            { 'text' => 'げんご' }
          ],

          'senses' => [
            { 'text' => 'word' },
            { 'text' => 'vocabulary' }
          ]
        }
      end

      let (:word) { Word.new(attributes) }

      it 'should set ID' do
        expect(word.id).to eq(attributes['id'])
      end

      it 'should set priority' do
        expect(word.priority).to eq(attributes['priority'])
      end

      it 'should set literals' do
        true_texts = attributes['literals'].map{ |value| value['text'] }
        actual_texts = word.literals.map { |literal| literal.text }
        
        expect(actual_texts).to eq(true_texts)
      end

      it 'should set readings' do
        true_texts = attributes['readings'].map{ |value| value['text'] }
        actual_texts = word.readings.map { |reading| reading.text }
        
        expect(actual_texts).to eq(true_texts)
      end

      it 'should set senses' do
        true_texts = attributes['senses'].map{ |value| value['text'] }
        actual_texts = word.senses.map { |sense| sense.text }
        
        expect(actual_texts).to eq(true_texts)
      end
    end
  end

  describe '#to_hash' do
    let(:word) { Word.new }

    it 'should exclude score' do
      word.score = 5
      hash = word.to_hash

      expect(hash['score']).to be_nil
    end
  end
end
