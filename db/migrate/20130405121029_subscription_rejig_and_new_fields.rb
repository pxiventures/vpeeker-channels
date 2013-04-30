class SubscriptionRejigAndNewFields < ActiveRecord::Migration
  def up
    
    # remove indexes and re-create so that user_id is no longer unique but reference is.
    remove_index :subscriptions, [:reference]
    remove_index :subscriptions, [:user_id]
    add_index :subscriptions, [:reference], unique: true
    add_index :subscriptions, [:user_id]
    
    add_column :subscriptions, :end_date, :date
    add_column :subscriptions, :next_period_date, :date
    add_column :subscriptions, :status, :string
    add_column :subscriptions, :status_reason, :string
    add_column :subscriptions, :total_price, :float
  end
  
  def down
    remove_index :subscriptions, [:reference]
    remove_index :subscriptions, [:user_id]
    add_index :subscriptions, [:reference]
    add_index :subscriptions, [:user_id], unique: true
    
    remove_column :subscriptions, :end_date
    remove_column :subscriptions, :next_period_date
    remove_column :subscriptions, :status
    remove_column :subscriptions, :status_reason
    remove_column :subscriptions, :total_price
  end

end
