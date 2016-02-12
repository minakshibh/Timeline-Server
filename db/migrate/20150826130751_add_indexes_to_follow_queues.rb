class AddIndexesToFollowQueues < ActiveRecord::Migration
  def change
    add_index :follow_queues, ["follower_id", "follower_type"],     :name => "fk_follows"
    add_index :follow_queues, ["followable_id", "followable_type"], :name => "fk_followables"
  end
end
