

class String
  Mojinizer::ROM_TO_KATA2['wi'] = 'ウィ'
  Mojinizer::ROM_TO_KATA2['we'] = 'ウェ'
  
  DOUBLE_VOWEL_PATTERN = /([aiueo])\1/
  DOUBLE_VOWEL_REPLACEMENT = '\1ー'

  alias_method :mojinizer_katakana, :katakana
  alias_method :mojinizer_hiragana, :hiragana
  alias_method :mojinizer_katakana?, :katakana?

  def katakana
    normalized = gsub(DOUBLE_VOWEL_PATTERN, DOUBLE_VOWEL_REPLACEMENT)

    normalized.mojinizer_katakana
  end

  def hiragana
    normalized = gsub('dzu', 'du')

    normalized.mojinizer_hiragana
  end

  def katakana?
    normalized = tr('ー', '')
    
    normalized.mojinizer_katakana?
  end
end
