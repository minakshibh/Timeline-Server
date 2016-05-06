class AddFollowerCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :followers_count, :integer, :default => 0
    add_column :timelines, :followers_count, :integer, :default => 0
  end
end
