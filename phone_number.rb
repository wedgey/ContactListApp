class PhoneNumber

  def initialize(label, number)
    @label = label
    @number = number
  end

  def to_s
    "#{@label}: #{@number}"
  end

end