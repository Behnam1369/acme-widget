# frozen_string_literal: true

# Product represents an item in the shop's catalogue.
class Product
  attr_reader :name, :code, :price

  @catalogue = {}

  def initialize(name, code, price)
    @name = name
    @code = code
    @price = price
  end

  def add
    raise ArgumentError, 'Code must be a non-empty String' unless @code.is_a?(String) && !@code.empty?
    raise ArgumentError, 'Name must be a non-empty String' unless @name.is_a?(String) && !@name.empty?
    raise ArgumentError, 'Price must be a positive number' unless @price.is_a?(Numeric) && @price.positive?

    self.class.catalogue[@code] = self
  end

  def self.catalogue
    @catalogue ||= {}
  end

  def self.find(code)
    catalogue[code]
  end
end
