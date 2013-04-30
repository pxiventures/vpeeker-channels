class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :name, allow_nil: false
      t.string :search
      t.string :access_token
      t.string :access_token_secret
      t.string :last_tweet_id
      t.datetime :searched_at
      t.integer :interval
      t.boolean :running, allow_nil: false, default: false
      t.boolean :default_approved_state, default: true

      t.timestamps
    end
  end
end
