require 'pg'

# Represents a person in an address book.
# The ContactList class will work with Contact objects instead of interacting with the CSV file directly
class Contact < ActiveRecord::Base
  has_many :phone_numbers

end
