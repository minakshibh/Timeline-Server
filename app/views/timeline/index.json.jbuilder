##------------------------ Initial Code ---------------------------------------------##
# json.array! @timelines do |timeline|
#   json.merge! timeline.attributes
#   json.moments_count timeline.videos.count
#   json.moments_duration timeline.videos.sum(:duration)
#   json.followed @current_user.follows?(timeline)
#   json.liked @current_user.likes?(timeline)
#   json.blocked @current_user.blocked?(timeline)
# end

##-------------------------------------------------------------------------------------##


##------------------------ Modified Code ---------------------------------------------##
##----------------------- Added by Insonix -------------------------------------------##
json.array! @timelines do |timeline|
  json.merge! timeline.attributes
  json.moments_count timeline.videos.count
  json.moments_duration timeline.videos.sum(:duration)
  json.followed @current_user.follows?(timeline)
  json.liked @current_user.likes?(timeline)
  json.blocked @current_user.blocked?(timeline)
  if timeline.group_timeline.present?
    group_participant = []
    begin
      group_timeline = GroupTimeline.find_by_timeline_id(timeline.id)
      group_timeline.participants.push(group_timeline.user_id).each do |participant|
        participant.to_s.eql?(group_timeline.user_id.to_s) ?
            group_participant.push(User.find_by_id(participant).as_json.merge!(:isAdmin => true)) :
            group_participant.push(User.find_by_id(participant).as_json.merge!(:isAdmin => false))
      end
      json.user_id @current_user.id
      json.admin_id group_timeline.user_id
      json.admin_name group_timeline.user_name
      json.participants group_participant
    rescue Exception => error
    end
  end
end
##-------------------------------------------------------------------------------------##
