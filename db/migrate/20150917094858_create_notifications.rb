class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications, :id => false do |t|
      t.uuid :id, :primary_key => true
      t.uuid :user_id
      t.string :notification
      t.text :payload

      t.timestamps null: false
    end

    add_index :notifications, [:user_id], :name => "user_notifications"
  end
end
