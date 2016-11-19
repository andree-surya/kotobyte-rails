
class Word
  attr_accessor :id
  attr_accessor :score
  attr_accessor :priority
  attr_accessor :literals
  attr_accessor :readings
  attr_accessor :senses

  def initialize(attributes = {})

    @id = attributes['id']
    @priority = attributes['priority'] || 1

    @literals = (attributes['literals'] || []).map do |literal_attribute|
      Literal.new(literal_attribute)
    end

    @readings = (attributes['readings'] || []).map do |reading_attribute|
      Literal.new(reading_attribute)
    end

    @senses = (attributes['senses'] || []).map do |sense_attribute|
      Sense.new(sense_attribute)
    end
  end

  def to_hash
    instance_values.except 'score'
  end
end
