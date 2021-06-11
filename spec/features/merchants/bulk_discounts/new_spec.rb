require 'rails_helper'

RSpec.describe 'The new form for a merchant bulk discount' do
  before :each do
    @merchant = FactoryBot.create(:merchant)

    visit new_merchant_bulk_discount_path(@merchant)
  end

  describe 'new form,' do
    it 'has fields creating a new a discount' do
      within 'form' do
        expect(page).to have_field('bulk_discount[percentage_discount]')
        expect(page).to have_field('bulk_discount[quantity_threshold]')
        expect(page).to have_button('Submit')
      end
    end

    it 'navigates back to the show page of new discount with a success flash' do
      within 'form' do
        fill_in 'bulk_discount[percentage_discount]', with: '20'
        fill_in 'bulk_discount[quantity_threshold]', with: '10'
        click_button 'Submit'
      end

      new_discount = BulkDiscount.last

      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant))

      within '#flash-message' do
        expect(page).to have_content('Created new Discount')
      end

      within "#discount-#{new_discount.id}" do
        expect(page).to have_content("20%")
        expect(page).to have_content("10")
      end
    end

    it 'navigates to the new page with a failure flash' do
      within 'form' do
        fill_in 'bulk_discount[percentage_discount]', with: ''
        fill_in 'bulk_discount[quantity_threshold]', with: '10'
        click_button 'Submit'
      end

      expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant))

      within '#flash-message' do
        expect(page).to have_content("Couldn't create discount")
      end
    end
  end
end