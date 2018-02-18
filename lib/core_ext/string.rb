

class String
  Mojinizer::ROM_TO_KATA2['wi'] = 'ウィ'
  Mojinizer::ROM_TO_KATA2['we'] = 'ウェ'
  
  DOUBLE_VOWEL_PATTERN = /([aiueo])\1/
  DOUBLE_VOWEL_REPLACEMENT = '\1ー'

  alias_method :mojinizer_katakana, :katakana
  alias_method :mojinizer_hiragana, :hiragana
  alias_method :mojinizer_katakana?, :katakana?

  def katakana
    gsub(DOUBLE_VOWEL_PATTERN, DOUBLE_VOWEL_REPLACEMENT).mojinizer_katakana
  end

  def hiragana
    gsub('dzu', 'du').gsub('nn', "n'n").mojinizer_hiragana
  end

  def katakana?
    tr('ー', '').mojinizer_katakana?
  end
end
