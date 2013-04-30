class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :uid, allow_nil: false
      t.string :access_token, allow_nil: false
      t.string :access_token_secret, allow_nil: false
      t.boolean :super_admin, allow_nil: false, default: false
      t.string :nickname, allow_nil: false

      t.timestamps
    end

    add_index :users, :uid, unique: true
  end
end
