class AddOverlayToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :overlay_text, :string
    add_column :videos, :overlay_position, :float
    add_column :videos, :overlay_size, :integer
    add_column :videos, :overlay_color, :string
  end
end
