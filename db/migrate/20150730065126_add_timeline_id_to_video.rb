class AddTimelineIdToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :timeline_id, :uuid
  end
end
