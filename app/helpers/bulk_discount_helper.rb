module BulkDiscountHelper
  def formatted_percentage_discount(discount)
    "%0.0f%%" % [discount.percentage_discount * 100]
  end
end