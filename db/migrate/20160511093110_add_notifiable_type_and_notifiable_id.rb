class AddNotifiableTypeAndNotifiableId < ActiveRecord::Migration
  def change
    add_column :notifications,:reportable_id,:uuid
    add_column :notifications,:reportable_type,:string
  end
end
