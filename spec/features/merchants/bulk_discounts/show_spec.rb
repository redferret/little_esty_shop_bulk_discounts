require 'rails_helper'

RSpec.describe 'The show page for a merchant bulk discount' do
  before :each do
    @merchant = FactoryBot.create(:merchant)
    customer = FactoryBot.create(:customer)
    @item_1 = FactoryBot.create(:item, merchant: @merchant)
    @item_2 = FactoryBot.create(:item, merchant: @merchant)

    @invoice = FactoryBot.create(:invoice, customer: customer)

    @invoice_item_1 = FactoryBot.create(:invoice_item, invoice: @invoice, item: @item_1, quantity: 5, unit_price: 2000)
    @invoice_item_2 = FactoryBot.create(:invoice_item, invoice: @invoice, item: @item_2, quantity: 2, unit_price: 3200)

    FactoryBot.create(:transaction, result: :success, invoice: @invoice)

    @bulk_discount = FactoryBot.create(:bulk_discount, merchant: @merchant, percentage_discount: 10, quantity_threshold: 5)
    
    visit merchant_bulk_discount_path(@merchant, @bulk_discount)
  end

describe 'invoice items list,' do
  it 'shows headers for each column' do
    within '#invoice-items' do
      expect(page).to have_content('Item Name')
      expect(page).to have_content('Original Unit Price')
      expect(page).to have_content('Discounted Price')
      expect(page).to have_content('Quantity')
      expect(page).to have_content('Total Revenue (Discount Included)')
    end
  end
  it 'shows the details of each invoice item' do
    within '#invoice-items' do
      within "#invoice-item-#{@invoice_item_1.id}" do
        expect(page).to have_content(@item_1.name)
        expect(page).to have_content('$20.00')
        expect(page).to have_content('$18.00')
        expect(page).to have_content('5')
        expect(page).to have_content('$90.00')
      end
      
      expect { find("#invoice-item-#{@invoice_item_2.id}") }.to raise_error Capybara::ElementNotFound
    end
  end
end

  describe 'discount details,' do
    it 'shows the details of the bulk discount' do
      within '#discount-details' do
        expect(page).to have_content("#{@bulk_discount.percentage_discount}%")
        expect(page).to have_content(@bulk_discount.quantity_threshold)
      end
    end

    it 'has a link to edit the discount page' do
      within '#discount-details' do
        expect(page).to have_link('Edit Discount', href: edit_merchant_bulk_discount_path(@merchant, @bulk_discount))
        click_link 'Edit Discount'
      end

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant, @bulk_discount))
    end
  end
end