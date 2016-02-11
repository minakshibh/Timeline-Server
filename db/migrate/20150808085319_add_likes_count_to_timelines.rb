class AddLikesCountToTimelines < ActiveRecord::Migration
  def change
    add_column :timelines, :likers_count, :integer, :default => 0
  end
end
