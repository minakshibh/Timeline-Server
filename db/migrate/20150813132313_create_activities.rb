class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities, :id => false do |t|
      t.uuid :id, :primary_key => true
      t.uuid :user
      t.string :action
      t.uuid :trackable
      t.string :trackable_type

      t.timestamps null: false
    end
  end
end
