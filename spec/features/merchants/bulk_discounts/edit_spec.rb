require 'rails_helper'

RSpec.describe 'The edit page for a merchant bulk discount' do
  before :each do
    @merchant = FactoryBot.create(:merchant)
    @bulk_discount = FactoryBot.create(:bulk_discount, merchant: @merchant)

    visit edit_merchant_bulk_discount_path(@merchant, @bulk_discount)
  end

  describe 'edit form,' do
    it 'has fields prefilled' do
      within 'form' do
        expect(page).to have_field('bulk_discount[percentage_discount]', with: @bulk_discount.percentage_discount)
        expect(page).to have_field('bulk_discount[quantity_threshold]', with: @bulk_discount.quantity_threshold)
        expect(page).to have_button('Submit')
      end
    end

    it 'navigates back to the show page with discount updated with a success flash' do
      within 'form' do
        fill_in 'bulk_discount[percentage_discount]', with: '20'
        fill_in 'bulk_discount[quantity_threshold]', with: '10'
        click_button 'Submit'
      end

      expect(current_path).to eq(merchant_bulk_discount_path(@merchant, @bulk_discount))

      within '#flash-message' do
        expect(page).to have_content('Updated Discount')
      end

      within "#discount-details" do
        expect(page).to have_content("20%")
        expect(page).to have_content("10")
      end
    end

    it 'navigates back to the edit page with a failure flash' do
      within 'form' do
        fill_in 'bulk_discount[percentage_discount]', with: ''
        fill_in 'bulk_discount[quantity_threshold]', with: ''
        click_button 'Submit'
      end

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant, @bulk_discount))

      within '#flash-message' do
        expect(page).to have_content("Couldn't update discount")
      end
    end
  end
end