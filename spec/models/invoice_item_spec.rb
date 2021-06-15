require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe "validations" do
    it { should validate_presence_of :invoice_id }
    it { should validate_presence_of :item_id }
    it { should validate_presence_of :quantity }
    it { should validate_presence_of :unit_price }
    it { should validate_presence_of :status }
  end
  describe "relationships" do
    it { should belong_to :invoice }
    it { should belong_to :item }
  end

  describe 'instance method,' do
    before :each do
      @merchant = Merchant.create!(name: 'Hair Care')
      @item_1 = FactoryBot.create(:item, merchant: @merchant)
      
      @customer_1 = FactoryBot.create(:customer)
      @invoice_1 = FactoryBot.create(:invoice, customer: @customer_1, status: 1)
      @invoice_item_1 = FactoryBot.create(:invoice_item, invoice: @invoice_1, item: @item_1, quantity: 10)
    end
    describe '#has_discount?' do
      it 'returns true if there is a discount for this invoice item' do
        discount = FactoryBot.create(:bulk_discount, merchant: @merchant, quantity_threshold: 10)
        expect(@invoice_item_1.has_discount?).to be false

        discount.apply_discount
        @invoice_item_1.reload

        expect(@invoice_item_1.has_discount?).to be true
      end

      it 'returns false if there is no discount for this invoice item' do
        expect(@invoice_item_1.has_discount?).to be false
      end
    end
  end
end
