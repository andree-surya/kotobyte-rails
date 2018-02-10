
class TokenStemmer

  def stem(token, output = SortedSet.new)

    case
      when token.end_with?('なかった', 'なくって', 'なければ', 'なくちゃ')
        stem(token[0...-4] + 'ない', output)

      when token.end_with?('なくて', 'なきゃ')
        stem(token[0...-3] + 'ない', output)

      when token.end_with?('ましょう')
        stem(token[0...-4] + 'ます', output)

      when token.end_with?('ません', 'ました', 'まして', 'ませば')
        stem(token[0...-3] + 'ます', output)

      when token.end_with?('します', 'さない')
        stem(token[0...-3] + 'す', output)

      when token.end_with?('たら', 'だら')
        stem(token[0...-1], output)

      when token.end_with?('です')
        stem(token[0...-2], output)

      when token.end_with?('ます')
        stem(token[0...-2], output)
        stem(token[0...-2] + 'る', output)

        output << token[0...-2] + 'む'

      when token.end_with?('れる', 'ない')
        stem(token[0...-2], output)
        stem(token[0...-2] + 'る', output)

      when token.end_with?('せる')
        stem(token[0...-2] + 'す', output)

      when token.end_with?('った', 'って')
        output << token[0...-2] + 'う'
        output << token[0...-2] + 'つ'
        output << token[0...-2] + 'る'

      when token.end_with?('んだ', 'んで')
        output << token[0...-2] + 'ぶ'
        output << token[0...-2] + 'む'
        output << token[0...-2] + 'ぬ'

      when token.end_with?('こう', 'けば', 'ける', 'かす', 'いた', 'いて')
        output << token[0...-2] + 'く'

      when token.end_with?('そう', 'せば', 'した', 'して')
        output << token[0...-2] + 'す'

      when token.end_with?('おう', 'えば', 'える', 'わす')
        output << token[0...-2] + 'う'

      when token.end_with?('ろう', 'れば', 'よう', 'らす')
        output << token[0...-2] + 'る'

      when token.end_with?('ぼう', 'べば', 'べる', 'ばす')
        output << token[0...-2] + 'ぶ'

      when token.end_with?('とう', 'てば', 'てる', 'たす')
        output << token[0...-2] + 'つ'

      when token.end_with?('のう', 'ねば', 'ねる', 'なす')
        output << token[0...-2] + 'ぬ'

      when token.end_with?('もう', 'めば', 'める')
        output << token[0...-2] + 'む'

      when token.end_with?('さす')
        output << token[0...-2] + 'す'

        # Handle Ichidan verb, 寝さす → 寝る
        output << token[0...-2] + 'る'

      when token.end_with?('わ', 'い', 'え')
        output << token[0...-1] + 'う'

      when token.end_with?('か', 'き', 'け')
        output << token[0...-1] + 'く'

      when token.end_with?('ら', 'り', 'れ')
        output << token[0...-1] + 'る'

      when token.end_with?('ば', 'び', 'べ')
        output << token[0...-1] + 'ぶ'

      when token.end_with?('ま', 'み', 'め')
        output << token[0...-1] + 'む'

      when token.end_with?('さ', 'し', 'せ')
        output << token[0...-1] + 'す'

      when token.end_with?('な', 'に', 'ね')
        output << token[0...-1] + 'ぬ'

      when token.end_with?('ち')
        output << token[0...-1] + 'つ'

      when token.end_with?('た', 'て')
        output << token[0...-1] + 'つ'

        # Handle Ichidan verb, 寝た or 寝て → 寝る
        output << token[0...-1] + 'る'
    end

    output << token
  end
end
