class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.string :reference

      t.timestamps
    end

    add_index :subscriptions, :user_id, unique: true
    add_index :subscriptions, :reference
  end
end
