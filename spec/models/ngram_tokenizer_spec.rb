require 'rails_helper'

describe NGramTokenizer do
  let(:tokenizer) { NGramTokenizer.new }
  
  it 'tokenize with token sizes 1 to N' do

    tokens = tokenizer.tokenize('文部科学省').sort
    expected_tokens = %w(
      文部科学省
      文部科学
      部科学省
      文部科
      部科学
      科学省
      文部
      部科
      科学
      学省
      文
      部
      科
      学
      省
    ).sort

    expect(tokens).to eq(expected_tokens)
  end
end