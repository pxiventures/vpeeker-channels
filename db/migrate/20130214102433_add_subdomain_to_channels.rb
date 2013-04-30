class AddSubdomainToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :subdomain, :string, allow_nil: false
    add_index :channels, :subdomain, {unique: true}
  end
end
