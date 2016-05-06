class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks, :id => false do |t|
      t.uuid :id, :primary_key => true
      t.uuid :user_id
      t.uuid :blockable_id
      t.string :blockable_type

      t.timestamps null: false
    end

    add_index :blocks, ["blockable_id", "blockable_type"], :name => "b_blockables"
  end
end
