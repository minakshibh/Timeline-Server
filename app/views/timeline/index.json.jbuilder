@group_timelines = []
GroupTimeline.all.each { |record| record.participants.each { |participant| @group_timelines.push(record) if participant.to_s.eql?(@current_user.id.to_s.gsub('-', '')) } }

if @timelines.present?
  json.array! @timelines do |timeline|
    json.merge! timeline.attributes
    json.moments_count timeline.videos.count
    json.moments_duration timeline.videos.sum(:duration)
    json.followed @current_user.follows?(timeline)
    json.liked @current_user.likes?(timeline)
    json.blocked @current_user.blocked?(timeline)
  end
end


if @group_timelines.present?
  group_participant = []
  begin
    json.array! @group_timelines do |my_timeline|
      single_timeline = Timeline.find_by_id(my_timeline.timeline_id)
      json.merge! single_timeline.attributes
      my_timeline.participants.each do |participant|
        group_participant.push(User.find_by_id(participant).as_json)
      end

      json.admin_id my_timeline.admin_id
      json.admin_name my_timeline.admin_name
      json.participants group_participant

    end
  rescue Exception => error
  end
end
