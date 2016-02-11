class AddLikersCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :likers_count, :integer, :default => 0
  end
end
