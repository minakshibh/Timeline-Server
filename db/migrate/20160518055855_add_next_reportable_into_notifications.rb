class AddNextReportableIntoNotifications < ActiveRecord::Migration
  def up
    change_table :notifications do |t|
      t.uuid :next_reportable_id
      t.string :next_reportable_type
    end
  end

  def down
    change_table :notifications do |t|
      t.uuid :next_reportable_id
      t.string :next_reportable_type
    end
  end
end
