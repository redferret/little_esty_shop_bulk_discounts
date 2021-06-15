module InvoiceItemHelper
  def calculate_discount(invoice_item)
    if invoice_item.has_discount?
      discount = 1 - (invoice_item.bulk_discount.percentage_discount / 100.0)
      unit_price = invoice_item.unit_price
      number_to_currency((unit_price * discount) / 100.0)
    else
      'No Discount'
    end
  end

  def calculate_total_revenue_with_discount(invoice_item)
    discount = 1 - (invoice_item.bulk_discount.percentage_discount / 100.0)
    total_revenue = (invoice_item.unit_price) * invoice_item.quantity
    number_to_currency((total_revenue * discount) / 100.0)
  end
end