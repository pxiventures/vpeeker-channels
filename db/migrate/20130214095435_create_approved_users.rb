class CreateApprovedUsers < ActiveRecord::Migration
  def change
    create_table :approved_users do |t|
      t.string :nickname, allow_nil: false

      t.timestamps
    end

    add_index :approved_users, :nickname, {unique: true}
  end
end
