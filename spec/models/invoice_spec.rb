require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end
  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many :transactions }
  end

  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')
    @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 1000, merchant_id: @merchant1.id, status: 1)
    @item_2 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5000, merchant_id: @merchant1.id)
    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
    @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 1, created_at: "2021-06-14 14:54:09")
    @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 1000, status: 2)
    @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 1, unit_price: 1000, status: 1)
    
    @item_3 = FactoryBot.create(:item, merchant: @merchant1, unit_price: 1000)
    @item_4 = FactoryBot.create(:item, merchant: @merchant1, unit_price: 2300)
    @customer_2 = FactoryBot.create(:customer)
    @invoice_2 = FactoryBot.create(:invoice, customer: @customer_2, status: 1)
    @invoice_item_3 = FactoryBot.create(:invoice_item, invoice: @invoice_2, item: @item_3, quantity: 2, unit_price: 2300)
    @invoice_item_4 = FactoryBot.create(:invoice_item, invoice: @invoice_2, item: @item_4, quantity: 3, unit_price: 1200)

    @discount_1 = FactoryBot.create(:bulk_discount, merchant: @merchant1, percentage_discount: 10, quantity_threshold: 5)
    @discount_1.apply_discount
  end

  describe "instance method," do
    describe '#total_revenue' do
      it 'calculates to the total revenue of the invoice' do
        expect(@invoice_1.total_revenue).to eq(10000)
      end
    end

    describe '#total_discounted_revenue' do
      it 'returns the total revenue with discounts that are applied' do
        expect(@invoice_1.total_discounted_revenue).to eq(9100.0)
      end

      it 'returns the sum from #non_discounted_revenue and #discounted_revenue' do
        allow_any_instance_of(Invoice).to receive(:non_discounted_revenue).and_return(1000)
        allow_any_instance_of(Invoice).to receive(:discounted_revenue).and_return(900)

        expect(@invoice_1.total_discounted_revenue).to eq(1900)
      end
    end

    describe '#invoice_creation_date' do
      it 'returns the creation date formatted' do
        expect(@invoice_1.invoice_creation_date).to eq "Monday, June 14, 2021"
      end
    end
    
  end
end
