
class LexemeStemmer

  IRREGULAR_する_BASES = %w(します しない しよう させる される した して しろ せよ さす)
  IRREGULAR_くる_BASES = %w(こさせる きます こない こさす こよう きた きて こい こる)

  #
  # Stem a Japanese lexeme into a set of possible stems.
  # e.g. 帰りなさい can be stemmed into 帰り and 帰る
  #
  # @param [<String>] string a Japanese lexeme
  # @return [<Set<String>>] Set of possible stems
  #
  def stem(string)
    recursive_stem(string, SortedSet.new).to_a
  end

  private 

    def recursive_stem(string, output)

      case
        when string.end_with?('なかった', 'なくって', 'なければ', 'なくちゃ')
          recursive_stem(string[0...-4] + 'ない', output)

        when string.end_with?('なくて', 'なきゃ')
          recursive_stem(string[0...-3] + 'ない', output)

        when string.end_with?('ましょう')
          recursive_stem(string[0...-4] + 'ます', output)

        when string.end_with?('くさせる')
          recursive_stem(string[0...-4] + 'い', output)

        when string.end_with?('かった', 'かろう')
          recursive_stem(string[0...-3] + 'い', output)

        when string.end_with?('ません', 'ました', 'まして', 'ませば')
          recursive_stem(string[0...-3] + 'ます', output)

        when string.end_with?('します', 'さない')
          recursive_stem(string[0...-3] + 'す', output)

        when string.end_with?('なさい')
          recursive_stem(string[0...-3], output)
          recursive_stem(string[0...-3] + 'る', output)

        when string.end_with?('たら', 'だら', 'たり', 'だり')
          recursive_stem(string[0...-1], output)

        when string.end_with?('です')
          recursive_stem(string[0...-2], output)

        when string.end_with?('くて')
          recursive_stem(string[0...-2] + 'い', output)

        when string.end_with?('ます')
          recursive_stem(string[0...-2], output)
          recursive_stem(string[0...-2] + 'る', output)
          recursive_stem(string[0...-2] + 'む', output)

        when string.end_with?('れる', 'ない')
          recursive_stem(string[0...-2], output)
          recursive_stem(string[0...-2] + 'る', output)

        when string.end_with?('せる')
          recursive_stem(string[0...-2] + 'す', output)

        when string.end_with?('った', 'って')
          recursive_stem(string[0...-2] + 'う', output)
          recursive_stem(string[0...-2] + 'つ', output)
          recursive_stem(string[0...-2] + 'る', output)

        when string.end_with?('んだ', 'んで')
          recursive_stem(string[0...-2] + 'ぶ', output)
          recursive_stem(string[0...-2] + 'む', output)
          recursive_stem(string[0...-2] + 'ぬ', output)

        when string.end_with?('いだ', 'いで')
          recursive_stem(string[0...-2] + 'ぐ', output)

        when string.end_with?('こう', 'けば', 'ける', 'かす', 'いた', 'いて')
          recursive_stem(string[0...-2] + 'く', output)

        when string.end_with?('そう', 'せば', 'した', 'して')
          recursive_stem(string[0...-2] + 'す', output)

        when string.end_with?('おう', 'えば', 'える', 'わす')
          recursive_stem(string[0...-2] + 'う', output)

        when string.end_with?('ろう', 'れば', 'よう', 'らす')
          recursive_stem(string[0...-2] + 'る', output)

        when string.end_with?('ぼう', 'べば', 'べる', 'ばす')
          recursive_stem(string[0...-2] + 'ぶ', output)

        when string.end_with?('とう', 'てば', 'てる', 'たす')
          recursive_stem(string[0...-2] + 'つ', output)

        when string.end_with?('のう', 'ねば', 'ねる', 'なす')
          recursive_stem(string[0...-2] + 'ぬ', output)

        when string.end_with?('もう', 'めば', 'める')
          recursive_stem(string[0...-2] + 'む', output)

        when string.end_with?('さす')
          recursive_stem(string[0...-2] + 'す', output)
          recursive_stem(string[0...-2] + 'る', output)

        when string.end_with?('わ', 'い', 'え')
          recursive_stem(string[0...-1] + 'う', output)

        when string.end_with?('か', 'き', 'け')
          recursive_stem(string[0...-1] + 'く', output)

        when string.end_with?('く')
          recursive_stem(string[0...-1] + 'い', output)

        when string.end_with?('ら', 'り', 'れ', 'ろ', 'よ')
          recursive_stem(string[0...-1] + 'る', output)

        when string.end_with?('ば', 'び', 'べ')
          recursive_stem(string[0...-1] + 'ぶ', output)

        when string.end_with?('ま', 'み', 'め')
          recursive_stem(string[0...-1] + 'む', output)

        when string.end_with?('さ', 'し', 'せ')
          recursive_stem(string[0...-1] + 'す', output)
          recursive_stem(string[0...-1] + 'い', output)

        when string.end_with?('な', 'に', 'ね')
          recursive_stem(string[0...-1] + 'ぬ', output)

        when string.end_with?('ち')
          recursive_stem(string[0...-1] + 'つ', output)

        when string.end_with?('た', 'て')
          recursive_stem(string[0...-1] + 'つ', output)
          recursive_stem(string[0...-1] + 'る', output)
      end

      case
        when IRREGULAR_する_BASES.include?(string)
          output << 'する'

        when IRREGULAR_くる_BASES.include?(string)
          output << 'くる'
      end

      output << string
    end
end
