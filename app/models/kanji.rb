
class Kanji
  attr_accessor :id
  attr_accessor :character
  attr_accessor :readings
  attr_accessor :meanings
  attr_accessor :jlpt
  attr_accessor :grade
  attr_accessor :strokes

  def initialize
    yield self if block_given?
  end

  def common?
    @grade&.between?(1, 6) || @grade == 8 || @jlpt&.between?(1, 4)
  end
end
