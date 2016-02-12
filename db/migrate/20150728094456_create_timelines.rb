class CreateTimelines < ActiveRecord::Migration
  def change
    create_table :timelines, :id => false do |t|
      t.uuid :id, :primary_key => true
      t.string :name
      t.uuid :user_id

      t.timestamps null: false
    end
  end
end
