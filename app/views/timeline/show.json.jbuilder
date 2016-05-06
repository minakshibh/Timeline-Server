json.merge! @timeline.attributes
json.moments_count @timeline.videos.count
json.moments_duration @timeline.videos.sum(:duration)
json.followed @current_user.follows?(@timeline)
json.liked @current_user.likes?(@timeline)
json.blocked @current_user.blocked?(@timeline)
if @timeline.group_timeline.present?
  group_participant = []
  begin
    group_timeline = GroupTimeline.find_by_timeline_id(@timeline.id)
    group_timeline.participants.each do |participant|
      group_participant.push(User.find_by_id(participant).as_json)
    end
    json.admin_id group_timeline.admin_id
    json.admin_name group_timeline.admin_name
    json.participants group_participant
  rescue Exception => error
  end
end