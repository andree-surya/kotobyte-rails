
describe Kanji do

  describe '#initialize' do
    context 'when called without parameters' do
      let (:kanji) { Kanji.new }

      it 'should have empty readings' do
        expect(kanji.readings).to be_empty
      end

      it 'should have empty meanings' do
        expect(kanji.meanings).to be_empty
      end

      it 'should have no strokes' do
        expect(kanji.strokes).to be_nil
      end
    end

    context 'when attributes parameters are provided' do
      let(:attributes) do
        {
          'id' => 5,
          'literal' => '食',
          'readings' => ['しょく', '食べ.る'],
          'meanings' => ['eat', 'meal'],
          'jlpt' => 2,
          'grade' => 6,
          'strokes' => ['xxx', 'yyy']
        }
      end

      let (:kanji) { Kanji.new(attributes) }

      it 'should set ID' do
        expect(kanji.id).to eq(attributes['id'])
      end

      it 'should set literal' do
        expect(kanji.literal).to eq(attributes['literal'])
      end

      it 'should set readings' do
        expect(kanji.readings).to eq(attributes['readings'])
      end

      it 'should set meanings' do
        expect(kanji.meanings).to eq(attributes['meanings'])
      end

      it 'should set JLPT level' do
        expect(kanji.jlpt).to eq(attributes['jlpt'])
      end

      it 'should set grade level' do
        expect(kanji.grade).to eq(attributes['grade'])
      end

      it 'should set strokes' do
        expect(kanji.strokes).to eq(attributes['strokes'])
      end
    end
  end

  describe '#common?' do
    let(:kanji) { Kanji.new }

    it 'should return true when grade is inside the expected range' do
      kanji.grade = 1
      expect(kanji).to be_common

      kanji.grade = 6
      expect(kanji).to be_common

      kanji.grade = 8
      expect(kanji).to be_common
    end

    it 'should return false when grade is outside the expected range' do
      kanji.grade = nil
      expect(kanji).not_to be_common

      kanji.grade = 0
      expect(kanji).not_to be_common

      kanji.grade = 7
      expect(kanji).not_to be_common
    end

    it 'should return true when JLPT is within the expected range' do
      kanji.jlpt = 1
      expect(kanji).to be_common

      kanji.jlpt = 4
      expect(kanji).to be_common
    end

    it 'should return false when JLPT is outside the expected range' do
      kanji.jlpt = nil
      expect(kanji).not_to be_common
      
      kanji.jlpt = 0
      expect(kanji).not_to be_common
      
      kanji.jlpt = 5
      expect(kanji).not_to be_common
    end
  end

  describe '#to_hash' do
    it 'should return a hash representation of kanji' do
      kanji = Kanji.new
      kanji.id = 5

      hash = kanji.to_hash
      expect(hash['id']).to eq(kanji.id)
    end
  end
end
