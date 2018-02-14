
class NGramTokenizer

  def initialize(max_n:)
    @max_n = max_n
  end

  def tokenize(string)

    tokens = []

    1.upto(@max_n) do |n|
      0.upto(string.length - n) do |index|
        tokens << string[index, n]
      end
    end

    tokens
  end
end