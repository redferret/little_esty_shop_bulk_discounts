require 'rails_helper'

RSpec.describe 'The index page for merchants bulk discounts,' do

  before :each do
    @merchant = FactoryBot.create(:merchant)
    @discount_1 = FactoryBot.create(:bulk_discount, merchant: @merchant, percentage_discount: 40, quantity_threshold: 10)
    @discount_2 = FactoryBot.create(:bulk_discount, merchant: @merchant, percentage_discount: 30, quantity_threshold: 15)

    visit merchant_bulk_discounts_path(@merchant)
  end

  it 'has a link to add a new discount' do
    expect(page).to have_link('Add new Discount', href: new_merchant_bulk_discount_path(@merchant))
  end

  describe 'discounts list,' do
    it 'shows the discounts with their attributes' do
      within "#discount-#{@discount_1.id}" do
        expect(page).to have_content("1.")
        expect(page).to have_content("40%")
        expect(page).to have_content("10")
      end
    end
    
    it 'has a link next to each discount that navigates to that discount show page' do
      within "#discount-#{@discount_1.id}" do
        expect(page).to have_link("View Discount")
        click_link "View Discount"
      end

      expect(current_path).to eq(merchant_bulk_discount_path(@merchant, @discount_1))
    end

    it 'has a button next to each discount to delete it' do
      within "#discount-#{@discount_1.id}" do
        expect(page).to have_link('Delete')
        click_link 'Delete'
      end

      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant))

      within '#bulk-discounts-list' do
        expect(page).to_not have_content('40%')
        expect(page).to_not have_content('10')
      end
    end
  end
end
