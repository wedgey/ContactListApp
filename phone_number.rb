class PhoneNumber < ActiveRecord::Base
  belongs_to :contact

  def to_s
    "#{label}: #{phone_number}"
  end

end