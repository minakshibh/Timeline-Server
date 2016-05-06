class ChangeIdTypeInFollowers < ActiveRecord::Migration
  def change
    change_column :follows, :follower_id, :uuid
    change_column :follows, :followable_id, :uuid
    change_column :follows, :id, :uuid
  end
end