
class Kanji 
  attr_accessor :id
  attr_accessor :literal
  attr_accessor :readings
  attr_accessor :meanings
  attr_accessor :jlpt
  attr_accessor :grade
  attr_accessor :strokes

  def initialize(attributes = {})
    @id = attributes['id']
    @literal = attributes['literal']
    @readings = attributes['readings'] || []
    @meanings = attributes['meanings'] || []
    @jlpt = attributes['jlpt']
    @grade = attributes['grade']
    @strokes = attributes['strokes']
  end

  def common?
    @grade&.between?(1, 6) || @grade == 8 || @jlpt&.between?(1, 4)
  end

  def to_hash
    instance_values
  end
end
