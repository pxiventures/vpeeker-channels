class ChangeTotalPriceToAString < ActiveRecord::Migration
  def up
    change_column :subscriptions, :total_price, :string
  end

  def down
    change_column :subscriptions, :total_price, :float
  end
end
