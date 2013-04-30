class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :channels
      t.boolean :embed
      t.string :fastspring_reference

      t.timestamps
    end
  end
end
