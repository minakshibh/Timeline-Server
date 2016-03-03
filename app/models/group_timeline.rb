class GroupTimeline < ActiveRecord::Base
  include ActiveUUID::UUID
  belongs_to :timeline
  belongs_to :user
  serialize :participants, Array

  # acts_as_likeable
  # acts_as_followable

  def self.public_or_own(current_user)
    if current_user
      joins(:user)
          .where("users.timelines_public = true OR group_timelines.user_id = ? OR group_timelines.user_id IN (?)",
                 current_user.id, Follow.users(current_user))
          .where("group_timelines.timeline_id NOT IN (?) AND group_timelines.user_id NOT IN (?)",
                 Block.select(:blockable_id).where(:blockable_type => 'Timeline', :user => current_user),
                 Block.select(:blockable_id).where(:blockable_type => 'User', :user => current_user))
    else
      joins(:user).where("users.timelines_public = true")
    end
  end

end

