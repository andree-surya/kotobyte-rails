
class TokenStemmer

  def stem(token, output = [])

    case
      when token.end_with?('なかった', 'なくって', 'なければ', 'なくちゃ')
        stem(token[0...-4] + 'ない', output)

      when token.end_with?('なくて', 'なきゃ')
        stem(token[0...-3] + 'ない', output)

      when token.end_with?('ましょう')
        stem(token[0...-4] + 'ます', output)

      when token.end_with?('ません', 'ました', 'まして', 'ませば')
        stem(token[0...-3] + 'ます', output)

      when token.end_with?('たら', 'だら')
        stem(token[0...-1], output)

      when token.end_with?('です')
        stem(token[0...-2], output)

      when token.end_with?('ます', 'れる', 'ない')
        stem(token[0...-2], output)
        stem(token[0...-2] + 'る', output)

      when token.end_with?('った', 'って')
        output << token[0...-2] + 'う'
        output << token[0...-2] + 'つ'
        output << token[0...-2] + 'る'

      when token.end_with?('んだ', 'んで')
        output << token[0...-2] + 'ぶ'
        output << token[0...-2] + 'む'
        output << token[0...-2] + 'ぬ'

      when token.end_with?('いた', 'いて')
        output << token[0...-2] + 'く'

      when token.end_with?('した', 'して')
        output << token[0...-2] + 'す'

      when token.end_with?('おう', 'えば', 'える')
        output << token[0...-2] + 'う'

      when token.end_with?('こう', 'けば', 'ける')
        output << token[0...-2] + 'く'

      when token.end_with?('ろう', 'れば', 'よう')
        output << token[0...-2] + 'る'

      when token.end_with?('ぼう', 'べば', 'べる')
        output << token[0...-2] + 'ぶ'

      when token.end_with?('とう', 'てば', 'てる')
        output << token[0...-2] + 'つ'

      when token.end_with?('もう', 'めば', 'める')
        output << token[0...-2] + 'む'

      when token.end_with?('のう', 'ねば', 'ねる')
        output << token[0...-2] + 'ぬ'

      when token.end_with?('そう', 'せば', 'せる')
        output << token[0...-2] + 'す'

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

      when token.end_with?('ち')
        output << token[0...-1] + 'つ'

      when token.end_with?('た', 'て')
        output << token[0...-1] + 'つ'

        # Handle Ichidan verb, 寝た or 寝て → 寝る
        output << token[0...-1] + 'る'

      when token.end_with?('な', 'に', 'ね')
        output << token[0...-1] + 'ぬ'
    end

    output << token
  end
end
