require 'rails_helper'
require 'core_ext/string'

describe String do

  describe '#hiragana' do
    it 'should replace "dzu" with "づ"' do
      expect('hikitsudzuki'.hiragana).to eq('ひきつづき')
    end
  end

  describe '#katakana' do
    it 'should map Romaji string to Katakana' do
      expect('sukauto'.katakana).to eq('スカウト')
      expect('indoneshia'.katakana).to eq('インドネシア')
    end

    it 'should replace long vowel with a dashed form' do
      expect('hantaa'.katakana).to eq('ハンター')
      expect('nyuuyooku'.katakana).to eq('ニューヨーク')
    end

    it 'should replace "wi" with "ウィ"' do
      expect('windo'.katakana).to eq('ウィンド')
    end

    it 'should replace "we" with "ウェ"' do
      expect('sofutowea'.katakana).to eq('ソフトウェア')
    end
  end

  describe '#katakana?' do
    it 'should recognize dash character as Katakana' do
      expect('ハンター').to be_katakana
      expect('ニューヨーク').to be_katakana
    end
  end
end
