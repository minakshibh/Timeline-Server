class CreateMentions < ActiveRecord::Migration
  def change
    create_table :mentions,:id=>false do |t|
      t.uuid :id,:primary_key=>true
      t.string  :mentioner_type
      t.uuid :mentioner_id
      t.string  :mentionable_type
      t.uuid :mentionable_id
      t.datetime :created_at
    end

    add_index :mentions, ["mentioner_id", "mentioner_type"],   :name => "fk_mentions"
    add_index :mentions, ["mentionable_id", "mentionable_type"], :name => "fk_mentionables"
  end
end
