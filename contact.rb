require 'pg'

# Represents a person in an address book.
# The ContactList class will work with Contact objects instead of interacting with the CSV file directly
class Contact

  attr_reader :id, :numbers
  attr_accessor :name, :email
  
  # Creates a new contact object
  # @param name [String] The contact's name
  # @param email [String] The contact's email address
  def initialize(name, email, id = nil)
    # TODO: Assign parameter values to instance variables.
    @name = name
    @email = email
    @id = id
    @numbers = []
  end

  def save
    if id.nil? # Insert
      res = Contact.connection.exec_params("INSERT INTO contacts (name, email) VALUES ($1, $2) RETURNING id;", [name, email])
      @id = res[0]['id']
      numbers.each do |num|
        Contact.connection.exec_params("INSERT INTO phone_numbers (contact_id, phone_number, label) VALUES ($1, $2, $3);", [id, num.number, num.label])
      end
    else # Update
      Contact.connection.exec_params("UPDATE contacts SET name = $1, email = $2 WHERE id = $3::int;", [name, email, id])
    end
  end

  def destroy
    Contact.connection.exec_params("DELETE FROM contacts WHERE id = $1::int;", [id])
    Contact.connection.exec_params("DELETE FROM phone_numbers WHERE contact_id = $1::int;", [id])
  end

  # Adds a number to a contact
  # @param number [PhoneNumber] The PhoneNumber object holding a number and its label
  def add_number(number)
    self.numbers << number
  end

  def get_numbers
    nums = Contact.connection.exec_params("SELECT label, phone_number FROM phone_numbers WHERE contact_id = $1;", [id])
  end

  # Provides functionality for managing contacts in the csv file.
  class << self
    @@connection = nil

    def connection
      @@connection = @connection || PG.connect(
        host: 'localhost',
        dbname: 'contact_list',
        user: 'development',
        password: 'development'
        )
    end

    # Opens 'contacts.csv' and creates a Contact object for each line in the file (aka each contact).
    # @return [Array<Contact>] Array of Contact objects
    def all
      # TODO: Return an Array of Contact instances made from the data in 'contacts.csv'.
      contacts = []
      res = connection.exec_params("SELECT * FROM contacts ORDER BY id;")
      res.each do |row|
        contact = Contact.new(row['name'], row['email'], row['id'])
        nums = contact.get_numbers
        nums.each do |numbers|
          contact.add_number(PhoneNumber.new(numbers['label'], numbers['phone_number']))
        end
        contacts << contact
      end
      contacts
    end

    # Creates a new contact, adding it to the csv file, returning the new contact.
    # @param name [String] the new contact's name
    # @param email [String] the contact's email
    def create(name, email, numbers = [])
      # exists = Contact.search_by_email(email)
      # return ['exist', Contact.search_by_email(email)] if exists
      contact = Contact.new(name, email)
      numbers.each do |number|
        contact.add_number(number)
      end
      contact.save
      contact
    end
    
    # Find the Contact in the 'contacts.csv' file with the matching id.
    # @param id [Integer] the contact id
    # @return [Contact, nil] the contact with the specified id. If no contact has the id, returns nil.
    def find(id)
      # TODO: Find the Contact in the 'contacts.csv' file with the matching id.
      res = connection.exec_params("SELECT * FROM contacts WHERE id = $1::int;", [id])
      if res.ntuples == 0
        nil
      else
        contact = Contact.new(res[0]['name'], res[0]['email'], res[0]['id'])
        nums = contact.get_numbers
        nums.each { |num| contact.add_number(PhoneNumber.new(num['label'], num['phone_number'])) }
      end
      contact
    end
    
    # Search for contacts by either name or email.
    # @param term [String] the name fragment or email fragment to search for
    # @return [Array<Contact>] Array of Contact objects.
    def search(term)
      # TODO: Select the Contact instances from the 'contacts.csv' file whose name or email attributes contain the search term.
      contacts = []
      res = connection.exec_params("SELECT * FROM contacts WHERE name LIKE '%' || $1 || '%' OR email LIKE '%' || $1 || '%' ORDER BY id;", [term])
      res.each do |row|
        contact = Contact.new(row['name'], row['email'], row['id'])
        nums = contact.get_numbers
        nums.each { |num| contact.add_number(PhoneNumber.new(num['label'], num['phone_number'])) }
        contacts << contact
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
