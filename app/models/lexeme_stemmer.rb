
class LexemeStemmer

  IRREGULAR_する_BASES = %w(します しない しよう させる される した して しろ せよ さす)
  IRREGULAR_くる_BASES = %w(こさせる きます こない こさす こよう きた きて こい こる)

  def stem(token, output = SortedSet.new)

    case
      when token.end_with?('なかった', 'なくって', 'なければ', 'なくちゃ')
        stem(token[0...-4] + 'ない', output)

      when token.end_with?('なくて', 'なきゃ')
        stem(token[0...-3] + 'ない', output)

      when token.end_with?('ましょう')
        stem(token[0...-4] + 'ます', output)

      when token.end_with?('くさせる')
        stem(token[0...-4] + 'い', output)

      when token.end_with?('かった', 'かろう')
        stem(token[0...-3] + 'い', output)

      when token.end_with?('ません', 'ました', 'まして', 'ませば')
        stem(token[0...-3] + 'ます', output)

      when token.end_with?('します', 'さない')
        stem(token[0...-3] + 'す', output)

      when token.end_with?('なさい')
        stem(token[0...-3], output)
        stem(token[0...-3] + 'る', output)

      when token.end_with?('たら', 'だら', 'たり', 'だり')
        stem(token[0...-1], output)

      when token.end_with?('です')
        stem(token[0...-2], output)

      when token.end_with?('くて')
        stem(token[0...-2] + 'い', output)

      when token.end_with?('ます')
        stem(token[0...-2], output)
        stem(token[0...-2] + 'る', output)
        stem(token[0...-2] + 'む', output)

      when token.end_with?('れる', 'ない')
        stem(token[0...-2], output)
        stem(token[0...-2] + 'る', output)

      when token.end_with?('せる')
        stem(token[0...-2] + 'す', output)

      when token.end_with?('った', 'って')
        stem(token[0...-2] + 'う', output)
        stem(token[0...-2] + 'つ', output)
        stem(token[0...-2] + 'る', output)

      when token.end_with?('んだ', 'んで')
        stem(token[0...-2] + 'ぶ', output)
        stem(token[0...-2] + 'む', output)
        stem(token[0...-2] + 'ぬ', output)

      when token.end_with?('こう', 'けば', 'ける', 'かす', 'いた', 'いて')
        stem(token[0...-2] + 'く', output)

      when token.end_with?('そう', 'せば', 'した', 'して')
        stem(token[0...-2] + 'す', output)

      when token.end_with?('おう', 'えば', 'える', 'わす')
        stem(token[0...-2] + 'う', output)

      when token.end_with?('ろう', 'れば', 'よう', 'らす')
        stem(token[0...-2] + 'る', output)

      when token.end_with?('ぼう', 'べば', 'べる', 'ばす')
        stem(token[0...-2] + 'ぶ', output)

      when token.end_with?('とう', 'てば', 'てる', 'たす')
        stem(token[0...-2] + 'つ', output)

      when token.end_with?('のう', 'ねば', 'ねる', 'なす')
        stem(token[0...-2] + 'ぬ', output)

      when token.end_with?('もう', 'めば', 'める')
        stem(token[0...-2] + 'む', output)

      when token.end_with?('さす')
        stem(token[0...-2] + 'す', output)
        stem(token[0...-2] + 'る', output)

      when token.end_with?('わ', 'い', 'え')
        stem(token[0...-1] + 'う', output)

      when token.end_with?('か', 'き', 'け')
        stem(token[0...-1] + 'く', output)

      when token.end_with?('く')
        stem(token[0...-1] + 'い', output)

      when token.end_with?('ら', 'り', 'れ', 'ろ', 'よ')
        stem(token[0...-1] + 'る', output)

      when token.end_with?('ば', 'び', 'べ')
        stem(token[0...-1] + 'ぶ', output)

      when token.end_with?('ま', 'み', 'め')
        stem(token[0...-1] + 'む', output)

      when token.end_with?('さ', 'し', 'せ')
        stem(token[0...-1] + 'す', output)
        stem(token[0...-1] + 'い', output)

      when token.end_with?('な', 'に', 'ね')
        stem(token[0...-1] + 'ぬ', output)

      when token.end_with?('ち')
        stem(token[0...-1] + 'つ', output)

      when token.end_with?('た', 'て')
        stem(token[0...-1] + 'つ', output)
        stem(token[0...-1] + 'る', output)
    end

    case
      when IRREGULAR_する_BASES.include?(token)
        output << 'する'

      when IRREGULAR_くる_BASES.include?(token)
        output << 'くる'
    end

    output << token
  end
end
