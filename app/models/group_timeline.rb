class GroupTimeline < ActiveRecord::Base
  include ActiveUUID::UUID
  belongs_to :timeline
  serialize :participants,Array
end

