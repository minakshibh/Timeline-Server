class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments, :id => false do |t|
      t.uuid :id, :primary_key => true
      t.string :title, :limit => 50, :default => ""
      t.text :comment
      t.uuid :commentable_id
      t.string :commentable_type
      t.uuid :user_id
      t.string :user_image
      t.string :role, :default => "comments"
      t.timestamps
    end

    add_index :comments, :commentable_type
    add_index :comments, :commentable_id
    add_index :comments, :user_id
  end

  def self.down
    drop_table :comments
  end
end
