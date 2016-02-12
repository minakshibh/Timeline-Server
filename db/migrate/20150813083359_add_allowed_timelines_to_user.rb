class AddAllowedTimelinesToUser < ActiveRecord::Migration
  def change
    add_column :users, :allowed_timelines_count, :integer, :default => 2
  end
end
