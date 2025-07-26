# frozen_string_literal: true

# Basket manages a shopping basket, applying offers and delivery charge rules.
class Basket
  attr_reader :catalogue, :delivery_charge_rules, :offers
  attr_accessor :items, :effective_items

  def initialize(catalogue, delivery_charge_rules, offers)
    @catalogue = catalogue
    @delivery_charge_rules = delivery_charge_rules
    @offers = offers
    @items = [] # original items added to the basket by user
    @effective_items = [] # final effective basket adjusted by delivery charge rules and offers
  end

  def add(product_code)
    return false unless @catalogue.key?(product_code)

    add_item_to_basket(product_code)
    apply_offers
    apply_delivery_charge_rules
    true
  end

  def total
    @effective_items.sum { |item| effective_price(item) }.round(2)
  end

  def print
    if @effective_items.count.zero?
      puts 'Your basket is empty.'
      return
    end
    print_items
    print_total
  end

  def reset
    @items = []
    @effective_items = []
  end

  private

  def effective_price(item)
    (item[:price] + (item[:offers] || []).sum { |offer| offer[:adjustment] }).round(2)
  end

  def add_item_to_basket(product_code)
    product = @catalogue[product_code]
    @items << {
      code: product.code,
      title: "(#{product.code}) #{product.name}",
      price: product.price,
      offers: []
    }
  end

  def print_items
    @effective_items.each_with_index do |item, _index|
      title = item[:title].to_s
      puts title.ljust(50) + format('$%.2f', item[:price]).rjust(10)
      print_item_offers(item)
    end
    puts '-' * 70
  end

  def print_item_offers(item)
    (item[:offers] || []).each do |offer|
      offer_title = "    #{offer[:title]}"
      puts offer_title.ljust(60) + format('$%.2f', offer[:adjustment]).rjust(10)
    end
  end

  def print_total
    puts 'total'.ljust(50) + format('$%.2f', total.to_s.rjust(10)).rjust(10)
  end

  def apply_offers
    @effective_items = Marshal.load(Marshal.dump(@items))
    @offers.each { |offer| offer.apply(self) }
  end

  def apply_delivery_charge_rules
    @delivery_charge_rules.each { |deliver_charge_rule| deliver_charge_rule.apply(self) }
  end
end
