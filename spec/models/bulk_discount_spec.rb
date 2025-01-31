require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
  describe 'validation,' do
    it { should validate_presence_of :percentage_discount }
    it { should validate_presence_of :quantity_threshold }
  end

  describe 'relationship,' do
    it { should belong_to :merchant }
  end

  before :each do
    @merchant = Merchant.create!(name: 'Hair Care')
    @item_1 = FactoryBot.create(:item, merchant: @merchant) 
    @item_2 = FactoryBot.create(:item, merchant: @merchant) 
    @item_3 = FactoryBot.create(:item, merchant: @merchant) 
    @item_4 = FactoryBot.create(:item, merchant: @merchant) 
    @item_5 = FactoryBot.create(:item, merchant: @merchant) 
    @item_6 = FactoryBot.create(:item, merchant: @merchant) 
    @item_7 = FactoryBot.create(:item, merchant: @merchant) 
    
    @customer_1 = FactoryBot.create(:customer)
    @invoice_1 = FactoryBot.create(:invoice, customer: @customer_1, status: 1)
    @invoice_item_1 = FactoryBot.create(:invoice_item, invoice: @invoice_1, item: @item_1, quantity: 1)
    @invoice_item_2 = FactoryBot.create(:invoice_item, invoice: @invoice_1, item: @item_2, quantity: 2)
    @invoice_item_3 = FactoryBot.create(:invoice_item, invoice: @invoice_1, item: @item_3, quantity: 5)
    @invoice_item_4 = FactoryBot.create(:invoice_item, invoice: @invoice_1, item: @item_4, quantity: 10)
    @invoice_item_5 = FactoryBot.create(:invoice_item, invoice: @invoice_1, item: @item_5, quantity: 15)
    @invoice_item_6 = FactoryBot.create(:invoice_item, invoice: @invoice_1, item: @item_6, quantity: 20)
    @invoice_item_7 = FactoryBot.create(:invoice_item, invoice: @invoice_1, item: @item_7, quantity: 25)

    @invoice_items = [
      @invoice_item_1, 
      @invoice_item_2, 
      @invoice_item_3, 
      @invoice_item_4, 
      @invoice_item_5,
      @invoice_item_6,
      @invoice_item_7
    ]
  end

  describe 'instance method,' do
    describe '#update_discounts' do
      it 'removes the discount and updates invoice items that can have other discounts applied to it' do
        discount_1 = FactoryBot.create(:bulk_discount, merchant: @merchant, quantity_threshold: 2)
        discount_2 = FactoryBot.create(:bulk_discount, merchant: @merchant, quantity_threshold: 10)
        discount_3 = FactoryBot.create(:bulk_discount, merchant: @merchant, quantity_threshold: 20)

        @invoice_items.each(&:reload)

        expect(@invoice_item_1.bulk_discount_id).to eq nil
        expect(@invoice_item_2.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_3.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_4.bulk_discount_id).to eq discount_2.id
        expect(@invoice_item_5.bulk_discount_id).to eq discount_2.id
        expect(@invoice_item_6.bulk_discount_id).to eq discount_3.id
        expect(@invoice_item_7.bulk_discount_id).to eq discount_3.id


        discount_2.destroy

        @invoice_items.each(&:reload)

        expect(@invoice_item_1.bulk_discount_id).to eq nil
        expect(@invoice_item_2.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_3.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_4.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_5.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_6.bulk_discount_id).to eq discount_3.id
        expect(@invoice_item_7.bulk_discount_id).to eq discount_3.id
      end
      it 'removes the discount and updates invoice items that can have other discounts applied to it' do
        discount_1 = FactoryBot.create(:bulk_discount, merchant: @merchant, quantity_threshold: 2)
        discount_2 = FactoryBot.create(:bulk_discount, merchant: @merchant, quantity_threshold: 10)
        discount_3 = FactoryBot.create(:bulk_discount, merchant: @merchant, quantity_threshold: 20)

        @invoice_items.each(&:reload)

        expect(@invoice_item_1.bulk_discount_id).to eq nil
        expect(@invoice_item_2.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_3.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_4.bulk_discount_id).to eq discount_2.id
        expect(@invoice_item_5.bulk_discount_id).to eq discount_2.id
        expect(@invoice_item_6.bulk_discount_id).to eq discount_3.id
        expect(@invoice_item_7.bulk_discount_id).to eq discount_3.id


        discount_3.destroy

        @invoice_items.each(&:reload)

        expect(@invoice_item_1.bulk_discount_id).to eq nil
        expect(@invoice_item_2.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_3.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_4.bulk_discount_id).to eq discount_2.id
        expect(@invoice_item_5.bulk_discount_id).to eq discount_2.id
        expect(@invoice_item_6.bulk_discount_id).to eq discount_2.id
        expect(@invoice_item_7.bulk_discount_id).to eq discount_2.id
      end
    end
    
    describe '#apply_discount' do
      it 'applies discount to all if no other exists' do
        discount = FactoryBot.create(:bulk_discount, merchant: @merchant, quantity_threshold: 1)

        @invoice_items.each(&:reload)
        expect(@invoice_item_1.bulk_discount_id).to eq discount.id
        expect(@invoice_item_2.bulk_discount_id).to eq discount.id
        expect(@invoice_item_3.bulk_discount_id).to eq discount.id
        expect(@invoice_item_4.bulk_discount_id).to eq discount.id
        expect(@invoice_item_5.bulk_discount_id).to eq discount.id
        expect(@invoice_item_6.bulk_discount_id).to eq discount.id
        expect(@invoice_item_7.bulk_discount_id).to eq discount.id
      end
      
      it 'applies only to invoice item quantities in range of another discount' do
        discount_1 = FactoryBot.create(:bulk_discount, merchant: @merchant, quantity_threshold: 5)
        
        @invoice_items.each(&:reload)
        
        expect(@invoice_item_1.bulk_discount_id).to eq nil
        expect(@invoice_item_2.bulk_discount_id).to eq nil
        expect(@invoice_item_3.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_4.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_5.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_6.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_7.bulk_discount_id).to eq discount_1.id

        discount_2 = FactoryBot.create(:bulk_discount, merchant: @merchant, quantity_threshold: 10)

        @invoice_items.each(&:reload)

        expect(@invoice_item_1.bulk_discount_id).to eq nil
        expect(@invoice_item_2.bulk_discount_id).to eq nil
        expect(@invoice_item_3.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_4.bulk_discount_id).to eq discount_2.id
        expect(@invoice_item_5.bulk_discount_id).to eq discount_2.id
        expect(@invoice_item_6.bulk_discount_id).to eq discount_2.id
        expect(@invoice_item_7.bulk_discount_id).to eq discount_2.id
        
        discount_2.quantity_threshold = 11
        discount_2.save

        @invoice_items.each(&:reload)
        
        expect(@invoice_item_1.bulk_discount_id).to eq nil
        expect(@invoice_item_2.bulk_discount_id).to eq nil
        expect(@invoice_item_3.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_4.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_5.bulk_discount_id).to eq discount_2.id
        expect(@invoice_item_6.bulk_discount_id).to eq discount_2.id
        expect(@invoice_item_7.bulk_discount_id).to eq discount_2.id

        discount_1.percentage_discount = 15
        
        discount_1.save

        @invoice_items.each(&:reload)
        
        expect(@invoice_item_1.bulk_discount_id).to eq nil
        expect(@invoice_item_2.bulk_discount_id).to eq nil
        expect(@invoice_item_3.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_4.bulk_discount_id).to eq discount_1.id
        expect(@invoice_item_5.bulk_discount_id).to eq discount_2.id
        expect(@invoice_item_6.bulk_discount_id).to eq discount_2.id
        expect(@invoice_item_7.bulk_discount_id).to eq discount_2.id
        
      end
    end
  end
end
