json.array! @users do |user|
  json.merge! user.attributes
  json.followed @current_user.follow_status(user)
  json.liked @current_user.likes?(user)
  json.blocked @current_user.blocked?(user)
end