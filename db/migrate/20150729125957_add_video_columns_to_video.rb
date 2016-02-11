class AddVideoColumnsToVideo < ActiveRecord::Migration
  def change
    add_attachment :videos, :video
  end
end