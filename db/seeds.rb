Merchant.all.each do |merchant|
  discount1 = BulkDiscount.new(merchant_id: merchant.id, percentage_discount: rand(2..5), quantity_threshold: 2)
  discount2 = BulkDiscount.new(merchant_id: merchant.id, percentage_discount: rand(10..15), quantity_threshold: 5)
  discount3 = BulkDiscount.new(merchant_id: merchant.id, percentage_discount: rand(20..25), quantity_threshold: 10)
end