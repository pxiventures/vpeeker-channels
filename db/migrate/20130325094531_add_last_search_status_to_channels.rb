class AddLastSearchStatusToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :last_search_status, :string
  end
end
