json.array! @timelines do |timeline|
  json.merge! timeline.attributes
  json.moments_count timeline.videos.count
  json.moments_duration timeline.videos.sum(:duration)
  json.followed @current_user.follows?(timeline)
  json.liked @current_user.likes?(timeline)
  json.blocked @current_user.blocked?(timeline)
end