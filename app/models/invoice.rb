class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :merchants

  enum status: { cancelled: 0, in_progress: 1, completed: 2 }

  def total_revenue
    invoice_items.sum("(unit_price * quantity) / 100.0").round(2)
  end

  def invoice_item_with_discount(invoice_item_id)
    discounts = bulk_discounts.where('invoice_items.quantity >= bulk_discounts.quantity_threshold')
                  .where(invoice_items: {id: invoice_item_id})
                  .select('MAX(bulk_discounts.percentage_discount) as percentage')
                  .select('invoice_items.id')
                  .select('bulk_discounts.id as bulk_discount_id')
                  .group('invoice_items.id, bulk_discounts.id')
                  
    discount = discounts.max_by do |discount|
      discount.percentage
    end
    
    if discount
      discount.bulk_discount_id
    end
  end

  def has_discount_applied?
    bulk_discounts.where('invoice_items.quantity >= bulk_discounts.quantity_threshold').count > 0
  end

  def discounted_revenue
    if has_discount_applied?
      result_set_sum_discounted_prices = ActiveRecord::Base.connection.execute(
      "SELECT SUM(discounted_prices) / 100.0 as sum_discounted_prices FROM (" +
      "#{bulk_discounts.where('invoice_items.quantity >= bulk_discounts.quantity_threshold')
                        .select('(1.0 - (MAX(bulk_discounts.percentage_discount) / 100.0)) * (invoice_items.unit_price) * invoice_items.quantity as discounted_prices')
                        .select('invoice_items.id')
                        .group('invoice_items.id').to_sql}) as sub_table")

      result_set_sum_normal_prices = ActiveRecord::Base.connection.execute(
      "SELECT SUM(normal_prices) / 100.0 as sum_normal_prices FROM (" +
      "#{bulk_discounts.select('CASE WHEN (invoice_items.quantity < MIN(bulk_discounts.quantity_threshold)) THEN (invoice_items.unit_price) * invoice_items.quantity ELSE 0 END as normal_prices')
                        .select('invoice_items.id')
                        .group('invoice_items.id').to_sql}) as sub_table")

      sum_discounted_prices = result_set_sum_discounted_prices.first['sum_discounted_prices']
      sum_normal_prices = result_set_sum_normal_prices.first['sum_normal_prices']
        
      (sum_discounted_prices + sum_normal_prices).round(2)
    else
      total_revenue
    end
  end
end
