json.timeline do
  json.merge! @timeline.attributes
  json.moments_count @timeline.videos.count
  json.moments_duration @timeline.videos.sum(:duration)
  json.followed @current_user.follows?(@timeline)
  json.liked @current_user.likes?(@timeline)
  json.blocked @current_user.blocked?(@timeline)
end

json.videos do
  json.array! @timeline.videos do |video|
    json.merge! video.attributes
    json.video_url video.video.url
    json.video_thumb video.video.url(:thumb)
    json.video_lowres video.video.url(:lowres)
  end
end