# Require pre-compiled Protobuf models file.
require Rails.root.join('lib', 'models_pb.rb').to_s

class Sentence
  attr_accessor :tokens

  def with(tokens:)
    self.tokens = tokens
  end
end