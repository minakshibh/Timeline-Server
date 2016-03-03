class ChangeAdminIdToUserIdInGroupTimeline < ActiveRecord::Migration
  def change
    rename_column :group_timelines,:admin_id,:user_id
    rename_column :group_timelines,:admin_name,:user_name
  end
end
