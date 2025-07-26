# frozen_string_literal: true

# DeliveryChargeRule defines and applies delivery charge rules to a basket.
class DeliveryChargeRule
  attr_reader :name, :rule

  @delivery_charge_rule = []

  def initialize(name, rule)
    @name = name
    @rule = rule
  end

  def apply(basket)
    rule.call(basket)
  end

  def add
    self.class.delivery_charge_rule << self
  end

  def self.delivery_charge_rule
    @delivery_charge_rule ||= []
  end

  def self.list
    delivery_charge_rule
  end
end
