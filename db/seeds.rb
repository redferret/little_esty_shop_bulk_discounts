Merchant.all.each do |merchant|
  rand(1..5).times do
    merchant.bulk_discounts << FactoryBot.create(:bulk_discount, merchant: merchant)
  end
end