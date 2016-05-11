class Notification < ActiveRecord::Base
  include ActiveUUID::UUID

  belongs_to :user
  belongs_to :notifiable_type,:polymorphic => true
  default_scope {order('created_at DESC')}
end
