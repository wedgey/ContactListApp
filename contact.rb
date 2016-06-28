require 'csv'

# Represents a person in an address book.
# The ContactList class will work with Contact objects instead of interacting with the CSV file directly
class Contact

  attr_reader :id, :numbers
  attr_accessor :name, :email
  
  # Creates a new contact object
  # @param name [String] The contact's name
  # @param email [String] The contact's email address
  def initialize(name, email, id)
    # TODO: Assign parameter values to instance variables.
    @name = name
    @email = email
    @id = id
    @numbers = []
  end

  # Adds a number to a contact
  # @param number [PhoneNumber] The PhoneNumber object holding a number and its label
  def add_number(number)
    self.numbers << number
  end

  # Provides functionality for managing contacts in the csv file.
  class << self

    # Opens 'contacts.csv' and creates a Contact object for each line in the file (aka each contact).
    # @return [Array<Contact>] Array of Contact objects
    def all
      # TODO: Return an Array of Contact instances made from the data in 'contacts.csv'.
      contacts = []
      CSV.foreach('contacts.csv') do |contact|
        contacts << Contact.new(contact[1], contact[2], contact[0])
      end
      contacts
    end

    # Creates a new contact, adding it to the csv file, returning the new contact.
    # @param name [String] the new contact's name
    # @param email [String] the contact's email
    def create(name, email, numbers = [])
      exists = Contact.search_by_email(email)
      return ['exist', Contact.search_by_email(email)] if exists
      contact = Contact.new(name, email, (self.all.count + 1))
      numbers.each do |number|
        contact.add_number(number)
      end
      CSV.open('contacts.csv', 'a') do |csv_file|
        nums = []
        contact.numbers.each do |number|
          nums << "#{number.to_s}"
        end
        csv_file.puts [contact.id, contact.name, contact.email] + nums
      end
      contact
    end
    
    # Find the Contact in the 'contacts.csv' file with the matching id.
    # @param id [Integer] the contact id
    # @return [Contact, nil] the contact with the specified id. If no contact has the id, returns nil.
    def find(id)
      # TODO: Find the Contact in the 'contacts.csv' file with the matching id.
      CSV.foreach('contacts.csv') do |contact|
        return Contact.new(contact[1],contact[2],contact[0]) if contact[0].to_i == id
      end
      nil
    end
    
    # Search for contacts by either name or email.
    # @param term [String] the name fragment or email fragment to search for
    # @return [Array<Contact>] Array of Contact objects.
    def search(term)
      # TODO: Select the Contact instances from the 'contacts.csv' file whose name or email attributes contain the search term.
      contacts = []
      CSV.foreach('contacts.csv') do |contact|
        if contact[1].match(/.*#{term}.*/) or contact[2].match(/.*#{term}.*/)
          contacts << Contact.new(contact[1],contact[2],contact[0])
        end
      end
      contacts
    end

    # Determines if the same email is already in the database.
    # @param term [String] an email to search for
    # @return [Contact, nil] with the contact with that email
    def search_by_email(email)
      # TODO: Select the Contact instances from the 'contacts.csv' file whose name or email attributes contain the search term.
      contact = CSV.read('contacts.csv').detect() { |contact| contact[2] == email }
      contact ? Contact.new(contact[1],contact[2],contact[0]) : nil
    end

  end

end
