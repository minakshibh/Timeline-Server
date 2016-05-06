class FollowQueue < ActiveRecord::Base
  include ActiveUUID::UUID

  belongs_to :follower, :polymorphic => true
  belongs_to :followable, :polymorphic => true

  def self.pending(user)
    User.where(:id => FollowQueue.select(:follower_id).where(:followable => user))
  end

end
