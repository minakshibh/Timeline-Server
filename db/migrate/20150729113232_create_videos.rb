class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos, :id => false do |t|
      t.uuid :id, :primary_key => true
      t.timestamps null: false
    end
  end
end
