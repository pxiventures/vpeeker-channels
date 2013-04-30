class ChangeUniqueVideoIndex < ActiveRecord::Migration
  def up
    remove_index :videos, :vine_url
    add_index :videos, [:channel_id, :vine_url], unique: true
  end

  def down
    remove_index :videos, [:channel_id, :vine_url]
    add_index :videos, :vine_url
  end
end
