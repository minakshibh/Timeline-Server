class Follow < Socialization::ActiveRecordStores::Follow
  include ActiveUUID::UUID

  def self.timelines(current_user)
    select(:followable_id).where(followable_type: "Timeline", follower_type: "User", follower_id: current_user.id)
  end

  def self.users(current_user)
    select(:followable_id).where(followable_type: "User", follower_type: "User", follower_id: current_user.id)
  end
end
