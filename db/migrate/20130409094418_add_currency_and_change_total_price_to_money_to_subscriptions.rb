class AddCurrencyAndChangeTotalPriceToMoneyToSubscriptions < ActiveRecord::Migration
  def up
    add_column :subscriptions, :currency, :string
    # Can't cast from a string
    remove_column :subscriptions, :total_price
    add_column :subscriptions, :total_price, :decimal, precision: 8, scale: 2
  end

  def down
    remove_column :subscriptions, :currency
    change_column :subscriptions, :total_price, :string
  end
end
