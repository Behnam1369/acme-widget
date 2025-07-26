# frozen_string_literal: true

# spec/basket_spec.rb
require 'spec_helper'
require_relative '../lib/product'
require_relative '../lib/offer'
require_relative '../lib/basket'
require_relative '../lib/delivery_charge_rule'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Basket' do
  before do
    Product.catalogue.clear
    Offer.offers.clear
    DeliveryChargeRule.delivery_charge_rule.clear

    # Products
    @product1 = Product.new('Red Widget', 'R01', 32.95)
    @product2 = Product.new('Green Widget', 'G01', 24.95)
    @product3 = Product.new('Blue Widget', 'B01', 7.95)
    [@product1, @product2, @product3].each(&:add)

    # Offer
    offer = Offer.new('Buy one red widget, get the second half price', lambda { |basket|
      red_widgets = basket.effective_items.select { |item| item[:code] == 'R01' }
      red_widgets.each_with_index do |item, index|
        next unless index.odd?

        item[:offers] << {
          title: offer.name,
          adjustment: (item[:price] * -0.5).round(2)
        }
      end
    })
    offer.add

    # Delivery Rule
    rule = DeliveryChargeRule.new('Delivery Charge', lambda { |basket|
      total = basket.total
      basket.effective_items << if total >= 90
                                  { title: rule.name, price: 0 }
                                elsif total >= 50
                                  { title: rule.name, price: 2.95 }
                                else
                                  { title: rule.name, price: 4.95 }
                                end
    })
    rule.add

    @basket = Basket.new(Product.catalogue, DeliveryChargeRule.list, Offer.list)
  end

  it 'adds valid product to basket' do
    expect(@basket.add('R01')).to be true
    expect(@basket.items.count).to eq(1)
  end

  it 'does not add invalid product to basket' do
    expect(@basket.add('INVALID')).to be false
    expect(@basket.items.count).to eq(0)
  end

  it 'calculates total without offers or delivery discount' do
    @basket.add('B01')
    # 7.95 + 4.95 = 12.90
    expect(@basket.total).to eq(12.90)
  end

  it 'applies offer on second Red Widget' do
    @basket.add('R01') # 32.95
    @basket.add('R01') # 32.95
    # -16.48 Second R01 discount
    # +4.95 delivery charge
    # total: 54.37
    expect(@basket.total).to eq(54.37)
  end

  it 'applies delivery discount for total >= 50' do
    @basket.add('G01') # 24.95
    @basket.add('R01') # 32.95
    # +2.95 delivery charge
    # total: 60.85
    expect(@basket.total).to eq(60.85)
  end

  it 'gives free delivery for total >= 90' do
    4.times { @basket.add('R01') } # 32.95 * 4 = 131.80
    # 32.96 Second R01 discount
    # No delivery charge
    # total: 82.37
    expect(@basket.total).to eq(98.84)
    delivery_item = @basket.effective_items.find { |i| i[:title] == 'Delivery Charge' }
    expect(delivery_item[:price]).to eq(0)
  end

  it 'resets the basket' do
    @basket.add('B01')
    expect(@basket.items.count).to eq(1)
    @basket.reset
    expect(@basket.items).to be_empty
    expect(@basket.total).to eq(0)
  end

  context 'Test cases in the challenge document:' do
    context 'when basket contains: B01, G01 ' do
      before do
        @basket.add('B01')
        @basket.add('G01')
      end
      it 'calculates total as $37.85' do
        expect(@basket.total).to eq(37.85)
      end
    end

    context 'when basket contains: R01, R01 ' do
      before do
        @basket.add('R01')
        @basket.add('R01')
      end
      it 'calculates total as $54.37' do
        expect(@basket.total).to eq(54.37)
      end
    end

    context 'when basket contains: R01, G01 ' do
      before do
        @basket.add('R01')
        @basket.add('G01')
      end
      it 'calculates total as $60.85' do
        expect(@basket.total).to eq(60.85)
      end
    end

    context 'when basket contains: B01, B01, R01, R01, R01 ' do
      before do
        @basket.add('B01')
        @basket.add('B01')
        @basket.add('R01')
        @basket.add('R01')
        @basket.add('R01')
      end
      it 'calculates total as $98.27' do
        expect(@basket.total).to eq(98.27)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
