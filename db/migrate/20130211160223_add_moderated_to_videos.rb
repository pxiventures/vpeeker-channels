class AddModeratedToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :moderated, :boolean, default: false
  end
end
