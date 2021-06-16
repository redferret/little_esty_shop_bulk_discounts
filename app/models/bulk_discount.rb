class BulkDiscount < ApplicationRecord
  after_create :apply_discount
  after_update :apply_discount
  after_destroy :update_discounts_after_destroy

  validates_presence_of :percentage_discount, numericality: true
  validates_presence_of :quantity_threshold, numericality: true

  has_many :invoice_items, dependent: :nullify
  belongs_to :merchant

  def apply_discount
    invoice_items.clear

    BulkDiscount.check_all_discounts_above quantity_threshold
    BulkDiscount.check_all_discounts_below quantity_threshold 
  end

  private

  def update_discounts_after_destroy
    next_discount_threshold = BulkDiscount.next_quantity_threshold_from quantity_threshold
    if next_discount_threshold
      BulkDiscount.check_all_discounts_below next_discount_threshold
    else
      previous_discount_threshold = BulkDiscount.previous_quantity_threshold_to quantity_threshold
      if previous_discount_threshold
        BulkDiscount.check_all_discounts_above previous_discount_threshold
      end
    end
  end

  def self.check_all_discounts_above(quantity_threshold)
    next_discount_threshold = BulkDiscount.next_quantity_threshold_from quantity_threshold
    
    if next_discount_threshold
      apply_to_all_up_to_the next_discount_threshold, quantity_threshold
    else
      apply_to_all_above quantity_threshold
    end
  end

  def self.check_all_discounts_below(quantity_threshold)
    previous_discount_threshold = BulkDiscount.previous_quantity_threshold_to quantity_threshold
    if previous_discount_threshold
      BulkDiscount.apply_to_all_discounts_below previous_discount_threshold, quantity_threshold
    end
  end

  def self.next_quantity_threshold_from(quantity_threshold)
    BulkDiscount.where('quantity_threshold > ?', quantity_threshold).minimum('quantity_threshold')
  end

  def self.previous_quantity_threshold_to(quantity_threshold)
    BulkDiscount.where('quantity_threshold < ?', quantity_threshold).maximum('quantity_threshold')
  end

  def self.apply_to_all_above(quantity_threshold)
    bulk_discount = BulkDiscount.where(bulk_discounts: {quantity_threshold: quantity_threshold}).first

    applied = InvoiceItem.joins("INNER JOIN items ON invoice_items.item_id = items.id")
                         .joins("INNER JOIN merchants ON items.merchant_id = merchants.id")
                         .joins("INNER JOIN bulk_discounts ON bulk_discounts.merchant_id = merchants.id")
                         .joins("INNER JOIN invoices ON invoices.id = invoice_items.invoice_id")
                         .where(merchants: {id: bulk_discount.merchant_id})
                         .where('invoice_items.quantity >= ?', quantity_threshold)
    bulk_discount.invoice_items << applied
  end

  def self.apply_to_all_up_to_the(next_quantity_threshold, from_quantity_threshold)
    bulk_discount = BulkDiscount.where(bulk_discounts: {quantity_threshold: from_quantity_threshold}).first

    applied = InvoiceItem.joins("INNER JOIN items ON invoice_items.item_id = items.id")
                         .joins("INNER JOIN merchants ON items.merchant_id = merchants.id")
                         .joins("INNER JOIN bulk_discounts ON bulk_discounts.merchant_id = merchants.id")
                         .joins("INNER JOIN invoices ON invoices.id = invoice_items.invoice_id")
                         .where(merchants: {id: bulk_discount.merchant_id})
                         .where('invoice_items.quantity >= ?', from_quantity_threshold)
                         .where('invoice_items.quantity < ?', next_quantity_threshold)
    bulk_discount.invoice_items << applied
  end

  def self.apply_to_all_discounts_below(previous_quantity_threshold, to_quantity_threshold)
    bulk_discount = BulkDiscount.where(bulk_discounts: {quantity_threshold: previous_quantity_threshold}).first
    
    applied = InvoiceItem.joins("INNER JOIN items ON invoice_items.item_id = items.id")
                         .joins("INNER JOIN merchants ON items.merchant_id = merchants.id")
                         .joins("INNER JOIN bulk_discounts ON bulk_discounts.merchant_id = merchants.id")
                         .joins("INNER JOIN invoices ON invoices.id = invoice_items.invoice_id")
                         .where(merchants: {id: bulk_discount.merchant_id})
                         .where('invoice_items.quantity >= ?', bulk_discount.quantity_threshold)
                         .where('invoice_items.quantity < ?', to_quantity_threshold)
    bulk_discount.invoice_items << applied
  end
end
