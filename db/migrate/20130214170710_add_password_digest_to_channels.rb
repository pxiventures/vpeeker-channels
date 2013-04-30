class AddPasswordDigestToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :password_digest, :string
  end
end
