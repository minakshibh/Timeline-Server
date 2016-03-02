class CreateGroupTimelines < ActiveRecord::Migration
  def self.up
    create_table :group_timelines, :id => false do |t|
      t.uuid :id, :primary_key => true
      t.uuid :timeline_id
      t.uuid :admin_id
      t.string :admin_name
      t.text :participants
      t.timestamps
    end
    add_index :group_timelines, :timeline_id
  end

  def self.down
    drop_table :group_timelines
  end

end
