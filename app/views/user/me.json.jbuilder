json.merge! @user.attributes
json.pending_followers @pending_followers
json.followees_users_count @user.followees_relation(User).count
if @auth_token
  json.jwt @auth_token
end