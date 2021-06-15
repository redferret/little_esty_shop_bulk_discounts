require 'rails_helper'

RSpec.describe 'invoices show page,' do
  before :each do
    @merchant_1 = FactoryBot.create(:merchant)

    @item_1 = FactoryBot.create(:item, merchant: @merchant_1)
    @item_2 = FactoryBot.create(:item, merchant: @merchant_1)
    @item_3 = FactoryBot.create(:item, merchant: @merchant_1)

    @customer_1 = FactoryBot.create(:customer)

    @invoice_1 = FactoryBot.create(:invoice, customer: @customer_1, status: :cancelled)

    @invoice_item_1 = FactoryBot.create(:invoice_item, invoice: @invoice_1, item: @item_1, quantity: 9, unit_price: 1000)
    @invoice_item_2 = FactoryBot.create(:invoice_item, invoice: @invoice_1, item: @item_2, quantity: 12, unit_price: 600)
    @invoice_item_3 = FactoryBot.create(:invoice_item, invoice: @invoice_1, item: @item_3, quantity: 2, unit_price: 1200)

    FactoryBot.create(:transaction, result: 1, invoice: @invoice_1)

    @discount = FactoryBot.create(:bulk_discount, merchant: @merchant_1, percentage_discount: 10, quantity_threshold: 5)

    visit merchant_invoice_path(@merchant_1, @invoice_1)
  end

  it 'shows the total discounted revenue' do
    within '#invoice-details' do
      expect(page).to have_content('Discounted Revenue')
      expect(page).to have_content('$169.80')
    end
  end
  
  it "shows the total revenue for this invoice" do
    within '#invoice-details' do
      expect(page).to have_content("$186.00")
    end
  end

  it "has the invoice information" do
    within '#invoice-details' do
      expect(page).to have_content(@invoice_1.id)
      expect(page).to have_content(@invoice_1.status)
      expect(page).to have_content(@invoice_1.created_at.strftime("%A, %B %-d, %Y"))
    end
  end

  it "has the customer information" do
    within '#invoice-details' do
      expect(page).to have_content(@customer_1.first_name)
      expect(page).to have_content(@customer_1.last_name)
    end
  end

  it "shows invoice item details with a discount link" do
    within '#invoice-items' do
      within "#invoice-item-#{@invoice_item_1.id}" do
        expect(page).to have_content(@item_1.name)
        expect(page).to have_content(@invoice_item_1.quantity)
        expect(page).to have_content('$10.00')
        expect(page).to have_content('$9.00')
        expect(page).to have_content(@invoice_item_1.status)
        expect(page).to have_link('View Discount', href: merchant_bulk_discount_path(@merchant_1, @discount))
      end
    end
  end

  it 'shows invoice item without a discount with no link to a discount' do
    within '#invoice-items' do
      within "#invoice-item-#{@invoice_item_3.id}" do
        save_and_open_page
        expect(page).to have_content(@item_3.name)
        expect(page).to have_content(@invoice_item_3.quantity)
        expect(page).to have_content('$12.00')
        expect(page).to have_content('No Discount')
        expect(page).to have_content(@invoice_item_3.status)
        expect(page).to_not have_link('View Discount')
      end
    end
  end


  it "shows a select field to update the invoice status" do
    within '#update-invoice-status' do
      select 'in_progress', from: 'invoice[status]'
      click_button "Update Invoice"
    end

    within '#update-invoice-status' do
      expect(page.has_select?('invoice[status]', selected: 'in_progress')).to eq true
    end
  end

end
