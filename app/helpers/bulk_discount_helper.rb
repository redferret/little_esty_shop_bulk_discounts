module BulkDiscountHelper
  def link_string(index, discount)
    "#{index + 1}. Discount Offered: #{formatted_percentage_discount(discount)}, Item Threshold: #{discount.quantity_threshold}"
  end

  def formatted_percentage_discount(discount)
    "%0.2f%%" % [discount.percentage_discount * 100]
  end
end