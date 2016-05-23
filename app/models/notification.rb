class Notification < ActiveRecord::Base
  include ActiveUUID::UUID

  belongs_to :user
  belongs_to :reportable,:polymorphic => true
  belongs_to :next_reportable,:polymorphic => true
  default_scope {order('created_at DESC')}
end
