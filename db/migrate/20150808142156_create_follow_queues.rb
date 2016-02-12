class CreateFollowQueues < ActiveRecord::Migration
  def change
    create_table :follow_queues, :id => false do |t|
      t.uuid :id, :primary_key => true
      t.string  :follower_type
      t.uuid :follower_id
      t.string  :followable_type
      t.uuid :followable_id
      t.boolean :approved, default: false
      t.datetime :created_at
    end
  end
end
