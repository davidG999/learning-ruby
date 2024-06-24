class Item
  attr_accessor :name, :quantity, :price, :status

  def initialize(name, quantity, price, status)
    @name = name
    @quantity = quantity
    @price = price
    @status = status
  end

  def details
    "Name: #{@name}, Quantity: #{@quantity}, Price: #{@price}, Status: #{@status}"
  end
end

class Inventory
  attr_reader :items

  def initialize(items = [])
    @items = items
  end

  def add_item(name, quantity, price, status)
    items << Item.new(name, quantity, price, status)
  end

  def remove_item(name)
    items.delete_if { |item| item.name == name }
  end

  def edit_item(name, quantity: nil, price: nil, status: nil)
    item = items.find { |i| i.name == name }

    if item
      item.quantity = quantity if quantity
      item.price = price if price
      item.status = status if status
    else
      puts 'Item not found!'
    end
  end

  def active_items
    active = items.select { |item| item.status == 'active' }
    active.each { |item| puts item.details }
    active
  end
end

def display_menu
  puts 'Available inventory actions:'
  puts '1. Add Item'
  puts '2. Remove Item'
  puts '3. Update Item'
  puts '4. View Inventory'
  puts '5. View Active Items'
  puts '6. Exit'
  print 'Enter the action number: '
end

def init_inventory
  inventory = Inventory.new

  loop do
    display_menu

    action = gets.chomp.to_i

    case action
    when 1
      name = ''
      loop do
        print 'Enter item name: '
        name = gets.chomp
        break unless name.empty?

        puts 'Item name cannot be empty. Please enter a valid name.'
      end

      quantity = nil
      loop do
        print 'Enter item quantity: '
        quantity_input = gets.chomp
        if quantity_input.match?(/^\d+$/)
          quantity = quantity_input.to_i
          break
        else
          puts 'Quantity must be a positive integer. Please enter a valid quantity.'
        end
      end

      price = nil
      loop do
        print 'Enter item price: '
        price_input = gets.chomp
        if price_input.match?(/^\d+$/)
          price = price_input.to_f
          break
        else
          puts 'Price must be a positive number. Please enter a valid price.'
        end
      end

      status = ''
      loop do
        print 'Enter item status (active/inactive): '
        status = gets.chomp.downcase
        break if %w[active inactive].include?(status)

        puts 'Status must be either "active" or "inactive". Please enter a valid status.'
      end

      inventory.add_item(name, quantity, price, status)
      puts 'Item added successfully!'

    when 2
      puts 'Available item names:'
      inventory.items.each { |item| puts item.name }

      name = ''
      loop do
        print 'Enter one of the available item names to remove: '
        name = gets.chomp
        break if inventory.items.any? { |item| item.name == name }
        puts 'Invalid item name. Please enter a valid item name from the list above.'
      end

      inventory.remove_item(name)
      puts 'Item removed successfully!'

    when 3
      puts 'Available item names:'
      inventory.items.each { |item| puts item.name }
      print 'Enter one of the available item names to update: '
      name = gets.chomp
      print 'Enter new quantity (leave blank to keep current): '
      quantity = gets.chomp
      quantity = quantity.empty? ? nil : quantity.to_i
      print 'Enter new price (leave blank to keep current): '
      price = gets.chomp
      price = price.empty? ? nil : price.to_f
      print 'Enter new status (active/inactive, leave blank to keep current): '
      status = gets.chomp
      status = status.empty? ? nil : status
      inventory.edit_item(name, quantity: quantity, price: price, status: status)
      puts 'Item updated successfully!'

    when 4
      puts "You have #{inventory.items.length} items in the inventory: "
      inventory.items.each { |item| puts item.details }

    when 5
      puts 'Active Items:'
      inventory.active_items

    when 6
      puts 'Exiting...'
      break

    else
      puts 'Invalid action, please try again.'
    end
  end
end

init_inventory
