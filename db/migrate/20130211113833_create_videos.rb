class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.references :channel
      t.string :video_url, allow_nil: false
      t.string :vine_url, allow_nil: false
      t.text :tweet
      t.boolean :approved

      t.timestamps
    end
    add_index :videos, :channel_id
    add_index :videos, :vine_url, unique: true
  end
end
