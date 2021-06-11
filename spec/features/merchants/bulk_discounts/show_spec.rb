require 'rails_helper'

RSpec.describe 'The show page for a merchant bulk discount' do
  before :each do
    @merchant = FactoryBot.create(:merchant)
    @bulk_discount = FactoryBot.create(:bulk_discount, merchant: @merchant)
    
    visit merchant_bulk_discount_path(@merchant, @bulk_discount)
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