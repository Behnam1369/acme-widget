# frozen_string_literal: true

require './data'

def render_menu
  puts 'Enter a product code to add it to your basket.'
  print_product_list
  print_menu_options
end

def print_product_list
  Product.catalogue.each_key do |product_code|
    name = Product.catalogue[product_code].name.ljust(20)
    price = Product.catalogue[product_code].price.to_s.rjust(10)
    puts "[#{product_code}] #{name} #{price} "
  end
end

def print_menu_options
  puts ''
  puts 'Other options:'
  puts '[p] Print basket details'
  puts '[e] EXit'
  puts '[r] Reset'
  puts ''
end

basket = Basket.new(Product.catalogue, DeliveryChargeRule.list, Offer.list)

puts 'Welcome to the Acme Widget shop.'
puts ''
input = ''

while input != 'e'
  render_menu
  input = gets.chomp

  case input
  when 'e'
    return
  when 'p'
    basket.print
  when 'r'
    basket.reset
    puts 'Your basket is empty now'
  else
    if basket.add(input)
      product_name = Product.find(input).name
      total_amount = format('$%.2f', basket.total)
      puts "1 \"#{product_name}\" was added to your basket successfully. " \
           "Total amount of the basket is #{total_amount}."
    else
      puts 'Wrong product code. Please try another one.'
    end
  end

  2.times { puts '' }
end
