require 'rails_helper'

describe Literal do

  describe '#initialize' do
    context 'when called without parameters' do
      
      let(:literal) { Literal.new }

      it 'should not have any text' do
        expect(literal.text).to be_nil
      end

      it 'should not have any status' do
        expect(literal.status).to be_nil
      end
    end

    context 'when called with attributes' do

      let(:attributes) { { 'text' => '言葉', 'status' => 'common'} }
      let(:literal) { Literal.new(attributes) }

      it 'should set text' do
        expect(literal.text).to eq(attributes['text'])
      end

      it 'should set status' do
        expect(literal.status).to eq(attributes['status'].to_sym)
      end
    end
  end

  describe '#status=' do
    let(:literal) { Literal.new }

    it 'should accept string parameter' do
      literal.status = 'irregular'

      expect(literal.status).to eq(:irregular)
    end

    it 'should accept common status' do
      expect(literal).not_to be_common

      literal.status = :common
      expect(literal).to be_common
    end

    it 'should accept irregular status' do
      expect(literal).not_to be_irregular

      literal.status = :irregular
      expect(literal).to be_irregular
    end

    it 'should accept outdated status' do
      expect(literal).not_to be_outdated

      literal.status = :outdated
      expect(literal).to be_outdated
    end
  end
end
