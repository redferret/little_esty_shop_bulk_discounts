class BulkDiscount < ApplicationRecord
  validates_presence_of :percentage_discount, numericality: true
  validates_presence_of :quantity_threshold

  has_many :invoice_items
  belongs_to :merchant

  def save_and_apply
    
  end

  def update_and_apply

  end
end
