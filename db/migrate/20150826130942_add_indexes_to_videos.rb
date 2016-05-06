class AddIndexesToVideos < ActiveRecord::Migration
  def change
    add_index :videos, [:timeline_id], :name => "video_timelines"
  end
end
