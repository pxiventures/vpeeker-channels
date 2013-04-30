class AddVideoLimitToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :video_limit, :integer
  end
end
