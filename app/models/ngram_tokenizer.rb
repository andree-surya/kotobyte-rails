
class NGramTokenizer

  #
  # Tokenize a string of Japanese characters into its set of all possible NGram permutations
  # e.g. 環境悪化 will be tokenized into:
  #   - 4-chars -> 環境悪化
  #   - 3-chars -> 環境悪、境悪化
  #   - 2-chars -> 環境、境悪、悪化
  #   - 1-chars -> 環、境、悪、化
  #
  # @param [<String>] string A string of Japanese characters
  # @return [<Array<String>] All possible NGram permutations
  #
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