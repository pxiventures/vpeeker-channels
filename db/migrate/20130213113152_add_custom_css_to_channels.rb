class AddCustomCssToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :custom_css, :text
  end
end
