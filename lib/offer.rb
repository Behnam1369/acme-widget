# frozen_string_literal: true

# Offer defines and applies promotional offers to a basket.
class Offer
  attr_reader :name, :rule

  @offers = []

  def initialize(name, rule)
    @name = name
    @rule = rule
  end

  def apply(basket)
    rule.call(basket)
  end

  def add
    self.class.offers << self
  end

  def self.offers
    @offers ||= []
  end

  def self.list
    offers
  end
end
