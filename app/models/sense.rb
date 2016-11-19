
class Sense
  attr_accessor :text
  attr_accessor :categories # Lexical categories
  attr_accessor :sources # Source languages
  attr_accessor :labels
  attr_accessor :notes

  def initialize(attributes = {})

    @text = attributes['text'] || ''
    @categories = attributes['categories'] || []
    @sources = attributes['sources'] || []

    @labels = attributes['labels'] || []
    @notes = attributes['notes'] || []
  end
end
