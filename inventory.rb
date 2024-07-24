# frozen_string_literal: true

class Item
  attr_reader :id, :name, :quantity, :price, :status

  @id_counter = 1

  class << self
    attr_accessor :id_counter
  end

  def initialize(name, quantity, price, status)
    @id = self.class.id_counter
    self.class.id_counter += 1
    self.name = name
    self.quantity = quantity
    self.price = price
    self.status = status
  end

  def details
    "ID: #{@id}, Name: #{@name}, Quantity: #{@quantity}, Price: #{@price}, Status: #{@status}"
  end

  def update(attributes)
    attributes.each do |key, value|
      setter_method = "#{key}="
      send(setter_method, value) if respond_to?(setter_method) && key != :id && !value.nil?
    end
  end

  def self.validate_name(name)
    raise 'Item name cannot be empty.' if name.strip.empty?
  end

  def self.validate_quantity(quantity)
    raise 'Quantity must be a positive integer.' unless quantity.is_a?(Integer) && quantity.positive?
  end

  def self.validate_price(price)
    raise 'Price must be a positive number.' unless price.is_a?(Numeric) && price >= 0
  end

  def self.validate_status(status)
    valid_statuses = %w[active inactive]
    raise 'Status must be either "active" or "inactive".' unless valid_statuses.include?(status)
  end

  private

  def name=(name)
    self.class.validate_name(name)
    @name = name
  end

  def quantity=(quantity)
    self.class.validate_quantity(quantity)
    @quantity = quantity
  end

  def price=(price)
    self.class.validate_price(price)
    @price = price
  end

  def status=(status)
    s = status.downcase
    self.class.validate_status(s)
    @status = s
  end
end

class Inventory
  attr_reader :items

  def initialize(items = [])
    @items = items
  end

  def add_item(name, quantity, price, status)
    items << Item.new(name, quantity, price, status)
    puts 'Item added successfully!'
  rescue StandardError => e
    puts e.message
  end

  def remove_item(id)
    item = find_item(id)
    if item
      items.delete(item)
      puts "Item with ID '#{id}' removed successfully!"
    else
      puts 'Item not found!'
    end
  end

  def edit_item(id, attributes = {})
    item = find_item(id)
    if item
      begin
        item.update(attributes)
        puts 'Item updated successfully!'
      rescue StandardError => e
        puts e.message
      end
    else
      puts 'Item not found!'
    end
  end

  def active_items
    items.select { |item| item.status == 'active' }
  end

  def display_items(items_to_display = items)
    items_to_display.each { |item| puts item.details }
  end

  def find_item(id)
    items.find { |i| i.id == id }
  end
end

class App
  def self.run
    inventory = Inventory.new

    loop do
      display_menu
      action = gets.chomp.to_i

      case action

      when 1
        name = get_valid_input('Enter item name: ', Item.method(:validate_name))
        quantity = get_valid_input('Enter item quantity: ', Item.method(:validate_quantity), &:to_i)
        price = get_valid_input('Enter item price: ', Item.method(:validate_price)) { |i| Float(i) }
        status = get_valid_input('Enter item status: ', Item.method(:validate_status), &:downcase)

        inventory.add_item(name, quantity, price, status)

      when 2
        puts 'Available items:'
        inventory.display_items

        id = get_valid_input('Enter the ID of the item to remove: ',
                             ->(input) { raise 'Item not found.' unless inventory.find_item(input) }, &:to_i)

        inventory.remove_item(id)

      when 3
        puts 'Available items:'
        inventory.display_items

        id = get_valid_input(
          'Enter the ID of the item to update: ',
          ->(input) { raise 'Item not found.' unless inventory.find_item(input) }, &:to_i
        )
        quantity = get_valid_input(
          'Enter item quantity (leave blank to keep current): ',
          lambda { |input|
            (input.is_a?(String) && input.empty?) || Item.validate_quantity(input)
          }
        ) { |i| Integer(i) }
        price = get_valid_input(
          'Enter item price: (leave blank to keep current): ',
          lambda { |input|
            (input.is_a?(String) && input.empty?) || Item.validate_price(input)
          }
        ) { |i| Float(i) }
        status = get_valid_input(
          'Enter item status: (leave blank to keep current): ',
          ->(input) { input.empty? || Item.validate_status(input) }, &:downcase
        )

        attributes = {}
        attributes[:quantity] = quantity unless quantity.is_a?(String) && quantity.empty?
        attributes[:price] = price unless price.is_a?(String) && price.empty?
        attributes[:status] = status unless status.empty?

        inventory.edit_item(id, attributes)

      when 4
        puts "You have #{inventory.items.length} items in the inventory:"
        inventory.display_items

      when 5
        puts 'Active Items:'
        inventory.display_items(inventory.active_items)

      when 6
        puts 'Exiting...'
        break

      else
        puts 'Invalid action, please try again.'
      end
    end
  end

  def self.display_menu
    puts 'Available inventory actions:'
    puts '1. Add Item'
    puts '2. Remove Item'
    puts '3. Update Item'
    puts '4. View Inventory'
    puts '5. View Active Items'
    puts '6. Exit'
    print 'Enter the action number: '
  end

  def self.get_valid_input(prompt, validate, &transform)
    loop do
      print prompt
      input = gets.chomp
      input = transform.call(input) if transform && !input.empty?
      validate.call(input)
      return input
    rescue StandardError => e
      puts e.message
    end
  end
end

App.run
