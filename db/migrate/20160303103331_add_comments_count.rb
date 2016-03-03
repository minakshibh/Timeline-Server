class AddCommentsCount < ActiveRecord::Migration
  def self.up
    add_column :timelines, :comments_count, :integer, :default => 0
    add_column :videos, :comments_count, :integer, :default => 0
    Timeline.reset_column_information
    Video.reset_column_information

    Timeline.all.each do |timeline|
      Timeline.update_counters timeline.id, :comments_count => timeline.comments.length
    end

    Video.all.each do |video|
      Video.update_counters video.id, :comments_count => video.comments.length
    end

  end

  def self.down
    remove_column :timelines, :comments_count
    remove_column :videoss, :comments_count
  end
end
