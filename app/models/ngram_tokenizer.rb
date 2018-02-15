
class NGramTokenizer

  def tokenize(string)

    tokens = []

    1.upto(string.length) do |token_size|
      0.upto(string.length - token_size) do |index|
        tokens << string[index, token_size]
      end
    end

    tokens
  end
end