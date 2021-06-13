require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
  describe 'validation,' do
    it { should validate_presence_of :percentage_discount }
    it { should validate_presence_of :quantity_threshold }
  end

  describe 'relationship,' do
    it { should belong_to :merchant }
    it { should have_many :invoice_items }
  end
end
