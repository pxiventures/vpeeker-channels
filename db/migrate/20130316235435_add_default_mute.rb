class AddDefaultMute < ActiveRecord::Migration
  def change
    add_column :channels, :default_mute, :boolean
  end
end
