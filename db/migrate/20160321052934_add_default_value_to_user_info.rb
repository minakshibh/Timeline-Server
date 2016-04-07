class AddDefaultValueToUserInfo < ActiveRecord::Migration
  def up
    change_column_default :users, :bio, ''
    change_column_default :users, :firstname, ''
    change_column_default :users, :lastname, ''
    change_column_default :users, :website, ''
    change_column_default :users, :other, ''
  end

  def down
    change_column_default :users, :bio, null
    change_column_default :users, :firstname, null
    change_column_default :users, :lastname, null
    change_column_default :users, :website, null
    change_column_default :users, :other, null
  end
end
