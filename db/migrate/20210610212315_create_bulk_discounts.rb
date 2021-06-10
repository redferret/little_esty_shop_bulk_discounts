class CreateBulkDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :bulk_discounts do |t|
      t.percentage_discount :float
      t.quantity_threshold :integer

      t.timestamps
    end
  end
end
