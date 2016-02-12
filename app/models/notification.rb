class Notification < ActiveRecord::Base
  include ActiveUUID::UUID

  belongs_to :user

  default_scope {order('created_at DESC')}
end
