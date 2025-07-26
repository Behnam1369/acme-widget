# frozen_string_literal: true

require './lib/product'
require './lib/offer'
require './lib/basket'
require './lib/delivery_charge_rule'

product1 = Product.new('Red Widget', 'R01', 32.95)
product2 = Product.new('Green Widget', 'G01', 24.95)
product3 = Product.new('Blue Widget', 'B01', 7.95)

product1.add
product2.add
product3.add

deliver_charge_rule1 = DeliveryChargeRule.new('Delivery Charge', lambda { |basket|
  basket.effective_items << { title: deliver_charge_rule1.name, price: 0 } and return if basket.total >= 90
  basket.effective_items << { title: deliver_charge_rule1.name, price: 2.95 } and return if basket.total >= 50

  basket.effective_items << { title: deliver_charge_rule1.name, price: 4.95 }
})

deliver_charge_rule1.add

offer1 = Offer.new('Buy one red widget, get the second half price', lambda { |basket|
  red_widgets_count = 0
  basket.effective_items.each do |item|
    next unless item[:code] == 'R01'

    red_widgets_count += 1
    item[:offers] << { title: offer1.name, adjustment: (item[:price] * -0.5).round(2) } if red_widgets_count.even?
  end
})

offer1.add
