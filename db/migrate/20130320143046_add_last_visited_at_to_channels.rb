class AddLastVisitedAtToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :last_visited_at, :timestamp
    Channel.update_all(last_visited_at: Time.now)
  end
end
