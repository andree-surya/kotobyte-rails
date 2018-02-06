
class TokenStemmer

  def stem(token, output = [])

    case
      when token.end_with?('なかった', 'なくって', 'なければ', 'なくちゃ')
        stem(token[0...-4] + 'ない', output)

      when token.end_with?('なくて', 'なきゃ')
        stem(token[0...-3] + 'ない', output)

      when token.end_with?('ません', 'ました', 'まして', 'ませば')
        stem(token[0...-3] + 'ます', output)

      when token.end_with?('たら', 'だら')
        stem(token[0...-1], output)

      when token.end_with?('です')
        stem(token[0...-2], output)

      when token.end_with?('ます')
        stem(token[0...-2], output)
        
        # Handle Ichidan verb, 着ます → 着る
        output << token[0...-2] + 'る' 

      when token.end_with?('ない')
        stem(token[0...-2], output)

        # Handle Ichidan verb, 食べない → 食べる
        output << token[0...-2] + 'る' 

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

      when token.end_with?('おう')
        output << token[0...-2] + 'う'

      when token.end_with?('こう')
        output << token[0...-2] + 'く'

      when token.end_with?('ろう')
        output << token[0...-2] + 'る'

      when token.end_with?('ぼう')
        output << token[0...-2] + 'ぶ'

      when token.end_with?('とう')
        output << token[0...-2] + 'つ'

      when token.end_with?('もう')
        output << token[0...-2] + 'む'

      when token.end_with?('のう')
        output << token[0...-2] + 'ぬ'

      when token.end_with?('そう')
        output << token[0...-2] + 'す'

      when token.end_with?('えば')
        output << token[0...-2] + 'う'
      
      when token.end_with?('けば')
        output << token[0...-2] + 'く'

      when token.end_with?('れば')
        output << token[0...-2] + 'る'

      when token.end_with?('べば')
        output << token[0...-2] + 'ぶ'

      when token.end_with?('てば')
        output << token[0...-2] + 'つ'

      when token.end_with?('めば')
        output << token[0...-2] + 'む'

      when token.end_with?('ねば')
        output << token[0...-2] + 'ぬ'

      when token.end_with?('せば')
        output << token[0...-2] + 'す'

      when token.end_with?('で')
        stem(token[0...-1], output)

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
