require_relative 'contact'
require_relative 'phone_number'
# Interfaces between a user and their contact list. Reads from and writes to standard I/O.
class ContactList

  # TODO: Implement user interaction. This should be the only file where you use `puts` and `gets`.
  def initialize
    return list_commands if ARGV.length == 0
    case ARGV[0]
    when 'new'
      new_contact
    when 'list'
      list_contacts
    when 'show'
      id = ARGV[1].to_i
      id.is_a?(Integer) && id != 0 ? show_contact(id) : (puts "Please include the id of the contact.")
    when 'search'
      # TODO: Implement searching for a contact
      search_contact(ARGV[1])
    else
      puts "That is an invalid command."
    end
  end

  def list_commands
    puts "Here is a list of availabled commands:"
    puts "\tnew\t- Create a new contact"
    puts "\tlist\t - List all contacts"
    puts "\tshow\t - Show a contact"
    puts "\tsearch\t - Search contacts"
  end

  def get_numbers(name)
    puts "Would you like to add a phone number for #{name}? y/n"
    phone_verify = STDIN.gets.strip.downcase
    numbers = []
    while phone_verify == 'y'
      puts "Please give us a label for this number."
      label = STDIN.gets.strip
      puts "What number would you like to add for #{name}'s #{label} number?"
      number = STDIN.gets.strip
      numbers << PhoneNumber.new(label, number)
      puts "Would you like to add another phone number for #{name}? y/n"
      phone_verify = STDIN.gets.strip.downcase
    end
    numbers
  end

  def new_contact
    puts "What is the full name of the new contact you'd like to add?"
    name = STDIN.gets.strip
    puts "What is #{name}'s email address?"
    email = STDIN.gets.strip
    numbers = get_numbers(name)

    contact = Contact.create(name, email, numbers)
    return puts "This email has already been added under #{contact[1].id}: #{contact[1].name}" if contact.is_a? Array
    puts "#{contact.id}, #{contact.name} has been added to your list."
  end

  def list_contacts
    count = 0
    Contact.all.each do |contact|
      puts "#{contact.id}: #{contact.name} (#{contact.email})"
      contact.numbers.each do |number|
        puts "\t" + number.to_s
      end
      
      count += 1
    end
    puts "---\n#{count} records total"
  end

  def show_contact(id)
    contact = Contact.find(id)
    if contact.nil?
      puts "Contact with #{id} was not found..."
    else
      puts "Id: #{contact.id}"
      puts "Name: #{contact.name}"
      puts "Email: #{contact.email}"
      contact.numbers.each do |number|
        puts number.to_s
      end
    end
  end

  def search_contact(term)
    contacts = Contact.search(term).each do |contact|
      puts "#{contact.id}: #{contact.name} (#{contact.email})"
      contact.numbers.each do |number|
        puts "\t" + number.to_s
      end
    end
    puts "---"
    puts contacts.count > 1 ? "#{contacts.count} records total" : "#{contacts.count} record total"
  end
end

app = ContactList.new
