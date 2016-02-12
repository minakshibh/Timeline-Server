class AddIndexToActivities < ActiveRecord::Migration
  def change
    remove_column :activities, :trackable
    add_column :activities, :trackable_id, :uuid
    remove_column :activities, :user
    add_column :activities, :user_id, :uuid
    add_index :activities, ["trackable_id", "trackable_type"], :name => "a_trackables"
  end
end
