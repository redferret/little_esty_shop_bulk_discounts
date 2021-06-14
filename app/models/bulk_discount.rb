class BulkDiscount < ApplicationRecord
  validates_presence_of :percentage_discount, numericality: true
  validates_presence_of :quantity_threshold

  has_many :invoice_items, dependent: :nullify
  belongs_to :merchant

  def apply_discount
    next_quantity_threshold = BulkDiscount.where('quantity_threshold > ?', quantity_threshold).minimum('quantity_threshold')
    previous_quantity_threshold = BulkDiscount.where('quantity_threshold < ?', quantity_threshold).maximum('quantity_threshold')

    if next_quantity_threshold.nil?
      apply_full_upper_bounds
    else
      apply_upper_bounds(next_quantity_threshold)
    end

    if previous_quantity_threshold
      apply_lower_bounds(previous_quantity_threshold)
    end
  end

  private
  def apply_full_upper_bounds
    applied = InvoiceItem.joins("INNER JOIN items ON invoice_items.item_id = items.id")
                         .joins("INNER JOIN merchants ON items.merchant_id = merchants.id")
                         .joins("INNER JOIN bulk_discounts ON bulk_discounts.merchant_id = merchants.id")
                         .joins("INNER JOIN invoices ON invoices.id = invoice_items.invoice_id")
                         .where(merchants: {id: merchant.id})
                         .where('invoice_items.quantity >= ?', quantity_threshold)
    invoice_items << applied
  end

  def apply_upper_bounds(next_quantity_threshold)
    applied = InvoiceItem.joins("INNER JOIN items ON invoice_items.item_id = items.id")
                         .joins("INNER JOIN merchants ON items.merchant_id = merchants.id")
                         .joins("INNER JOIN bulk_discounts ON bulk_discounts.merchant_id = merchants.id")
                         .joins("INNER JOIN invoices ON invoices.id = invoice_items.invoice_id")
                         .where(merchants: {id: merchant.id})
                         .where('invoice_items.quantity >= ?', quantity_threshold)
                         .where('invoice_items.quantity < ?', next_quantity_threshold)
    invoice_items << applied
  end

  def apply_lower_bounds(previous_quantity_threshold)
    bulk_discount = BulkDiscount.where(bulk_discounts: {quantity_threshold: previous_quantity_threshold}).first
    
    applied = InvoiceItem.joins("INNER JOIN items ON invoice_items.item_id = items.id")
                         .joins("INNER JOIN merchants ON items.merchant_id = merchants.id")
                         .joins("INNER JOIN bulk_discounts ON bulk_discounts.merchant_id = merchants.id")
                         .joins("INNER JOIN invoices ON invoices.id = invoice_items.invoice_id")
                         .where(merchants: {id: bulk_discount.merchant_id})
                         .where('invoice_items.quantity >= ?', bulk_discount.quantity_threshold)
                         .where('invoice_items.quantity < ?', quantity_threshold)
    bulk_discount.invoice_items << applied
  end
end
