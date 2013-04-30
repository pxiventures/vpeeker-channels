class AddGaTagToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :ga_tag, :string
  end
end
