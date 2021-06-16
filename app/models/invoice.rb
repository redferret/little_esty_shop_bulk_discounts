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

  def self.invoices_ready_to_ship(merchant_id)
    Invoice.joins(:invoice_items, :items).where(items: {merchant_id: merchant_id}, invoice_items: {status: 'packaged'}).distinct
  end

  def total_revenue
    invoice_items.sum("(unit_price * quantity)")
  end

  def invoice_creation_date
    created_at.strftime("%A, %B %d, %Y")
  end

  def total_discounted_revenue
    (non_discounted_revenue + discounted_revenue)
  end

  private
  
  def non_discounted_revenue
    revenue = invoice_items.joins('INNER JOIN items ON invoice_items.item_id = items.id')
                           .joins('INNER JOIN merchants ON items.merchant_id = merchants.id')
                           .where(invoice_items: {bulk_discount_id: nil})
                           .where('merchants.id = items.merchant_id')
                           .where(invoice_items: {invoice_id: id})
                           .sum('invoice_items.unit_price * invoice_items.quantity')
    return 0 if revenue.nil?
    revenue
  end
                          
  def discounted_revenue
    revenue = invoice_items.joins('INNER JOIN items ON invoice_items.item_id = items.id')
                           .joins('INNER JOIN merchants ON items.merchant_id = merchants.id')
                           .joins('INNER JOIN bulk_discounts ON bulk_discounts.id = invoice_items.bulk_discount_id')
                           .where('merchants.id = bulk_discounts.merchant_id')
                           .where(invoice_items: {invoice_id: id})
                           .sum('(1.0 - (bulk_discounts.percentage_discount / 100.0)) * (invoice_items.unit_price * invoice_items.quantity)')
    return 0 if revenue.nil?
    revenue
  end
end
