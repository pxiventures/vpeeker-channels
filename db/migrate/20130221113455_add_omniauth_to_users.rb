class AddOmniauthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :provider, :string
    execute "UPDATE users SET provider='twitter' WHERE true"
  end
end
