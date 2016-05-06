class ChangeIdTypeInLikes < ActiveRecord::Migration
  def change
    change_column :likes, :liker_id, :uuid
    change_column :likes, :likeable_id, :uuid
    change_column :likes, :id, :uuid
  end
end
