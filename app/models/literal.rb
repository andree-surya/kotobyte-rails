
class Literal
  attr_accessor :text
  attr_accessor :status

  def initialize(attributes = {})
    @text = attributes['text']
    @status = attributes['status']&.to_sym
  end

  def status=(value)
    @status = value&.to_sym
  end

  def common?
    @status == :common
  end

  def irregular?
    @status == :irregular
  end

  def outdated?
    @status == :outdated
  end
end
