require 'rails_helper'

RSpec.describe 'The index page for merchants bulk discounts,' do

  before :each do
    @merchant = FactoryBot.create(:merchant)
    @discount_1 = FactoryBot.create(:bulk_discount, merchant: @merchant, percentage_discount: 0.40, quantity_threshold: 10)
    @discount_2 = FactoryBot.create(:bulk_discount, merchant: @merchant, percentage_discount: 0.30, quantity_threshold: 15)

    visit merchant_bulk_discounts_path(@merchant)
  end

  describe 'discounts list,' do
    it 'shows the discounts with their attributes' do
      within '#discount-list' do
        expect(page).to have_content("1. Discount Offered: 40%, Item Threshold: 10")
      end
    end
    
    it 'has a link next to each discount that navigates to that discount show page' do
      expect(page).to have_link("2. Discount Offered: 30%, Item Threshold: 15")
      click_link "1. Discount Offered: 40%, Item Threshold: 10"

      expect(current_path).to eq(merchant_bulk_discount_path(@merchant, @discount_1))
    end
  end
end
