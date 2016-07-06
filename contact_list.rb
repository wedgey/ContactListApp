#!/usr/bin/env ruby
require 'active_record'
require_relative 'contact'
require_relative 'phone_number'
# Interfaces between a user and their contact list. Reads from and writes to standard I/O.
class ContactList

  # Output messages from Active Record to standard out
  # ActiveRecord::Base.logger = Logger.new(STDOUT)

  ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',
    database: 'contact_list',
    username: 'development',
    password: 'development',
    host: 'localhost',
    port: 5432,
    pool: 5,
    encoding: 'unicode',
    min_messages: 'error'
  )

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
    when 'update'
      id = ARGV[1].to_i
      id.is_a?(Integer) && id != 0 ? update_contact(id) : (puts "Please include the id of the contact.")
    when 'destroy'
      id = ARGV[1].to_i
      id.is_a?(Integer) && id != 0 ? destroy_contact(id) : (puts "Please include the id of the contact.")
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
    puts "\tupdate\t - Updates a contact's details"
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

    begin
      contact = Contact.create(name, email, numbers)
    rescue PG::UniqueViolation
      puts "This email has already been added!"
    else
    puts "#{contact.id}, #{contact.name} has been added to your list."
    end
  end

  def list_contacts
    Contact.all.order(:id).each do |contact|
      puts "#{contact.id}: #{contact.name} (#{contact.email})"
      contact.phone_numbers.each do |number|
        puts "\t" + number.to_s
      end
    end
    puts "---\n#{Contact.count} records total"
  end

  def show_contact(id)
    contact = Contact.find(id)
    if contact.nil?
      puts "Contact with ID: #{id} was not found..."
    else
      puts "Id: #{contact.id}"
      puts "Name: #{contact.name}"
      puts "Email: #{contact.email}"
      contact.phone_numbers.each do |number|
        puts number.to_s
      end
    end
  end

  def search_contact(term)
    term = "%#{term}%"
    contacts = Contact.where("name LIKE ? OR email LIKE ?", term, term).order(:id).each do |contact|
      puts "#{contact.id}: #{contact.name} (#{contact.email})"
      contact.phone_numbers.each do |number|
        puts "\t" + number.to_s
      end
    end
    puts "---"
    puts contacts.count > 1 ? "#{contacts.count} records total" : "#{contacts.count} record total"
  end

  def update_contact(id)
    contact = Contact.find(id)
    unless contact
      puts "No such contact with that id!"
      return
    end
    puts "What do you want to change the name: #{contact.name} to?"
    name = STDIN.gets.strip
    puts "What do you want to change the #{contact.name}'s email: #{contact.email} to?"
    email = STDIN.gets.strip
    # numbers = get_numbers(name)
    old_name = contact.name
    old_email = contact.email
    contact.name = name
    contact.email = email
    begin
      contact.save
    rescue PG::UniqueViolation
      puts "That email has already been used by someone else!"
    else
      puts "#{contact.id}, #{contact.name} has been updated in your list."
    end
  end

  def destroy_contact(id)
    contact = Contact.find(id)
    unless contact
      puts "No such contact with that id!"
      return
    end
    contact.destroy
  end
end

app = ContactList.new
