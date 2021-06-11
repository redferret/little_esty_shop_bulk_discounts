class Transaction < ApplicationRecord
  validates_presence_of :invoice_id,
                        :credit_card_number,
                        :result
  enum result: { failed: 0, success: 1 }

  belongs_to :invoice
end
