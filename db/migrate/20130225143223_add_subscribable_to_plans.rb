class AddSubscribableToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :subscribable, :boolean, default: true
  end
end
