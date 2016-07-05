class PhoneNumber
  attr_reader :label, :number

  def initialize(label, number)
    @label = label
    @number = number
  end

  def to_s
    "#{label}: #{number}"
  end

end