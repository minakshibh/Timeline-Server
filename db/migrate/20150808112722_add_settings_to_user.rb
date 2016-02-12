class AddSettingsToUser < ActiveRecord::Migration
  def change
    add_column :users, :timelines_public, :boolean, :default => true
    add_column :users, :approve_followers, :boolean, :default => false
  end
end
