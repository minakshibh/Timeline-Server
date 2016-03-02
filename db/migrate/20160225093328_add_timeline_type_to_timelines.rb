class AddTimelineTypeToTimelines < ActiveRecord::Migration
  def change
    add_column :timelines, :group_timeline, :boolean,:default => 0
    add_column :timelines, :description, :string,:default => ''
  end
end
