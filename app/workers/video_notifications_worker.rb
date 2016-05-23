class VideoNotificationsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'high'
  sidekiq_options retry: true
  sidekiq_options unique: :until_and_while_executing

  def perform(*args)
    activity_id = args[0]
    puts "=======activity_id=#{activity_id}===\n"
    activity = Activity.find_by_id(activity_id)
    user_id = activity.trackable.timeline.user.id
    puts "======activity=#{activity}=\n===trackable=#{activity.trackable}==/n====timeline=#{activity.trackable.timeline}==\n===user=#{activity.trackable.timeline.user}"
    followers = User.select(:id, :external_id).where(id: Follow.select(:follower_id).where(followable_type: "Timeline", follower_type: "User", followable_id: activity.trackable.timeline.id))
    external_id = {'$in' => followers.map { |u| u.external_id }.to_a.flatten}
    notification = "@#{activity.user.name} added a moment to ##{activity.trackable.timeline.name}."
    payload = {:timeline_id => activity.trackable.timeline.id, :video_id => activity.trackable_id, :name => activity.trackable.timeline.name, :action => activity.action}
    user_query = {'$inQuery' => {'where' => {'objectId' => external_id}, 'className' => '_User'}}


    pushdata = {:where => {:user => user_query},
                :data => {:alert => notification, :badge => 'Increment', :sound => 'default', 'content-available' => 1, :payload => payload}}

    # send REST call to Parse if we have a notification

    if notification
      uri = URI.parse("https://api.parse.com/1/push")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      response = nil

      http.start do |h|
        request = Net::HTTP::Post.new uri.request_uri
        request['X-Parse-Application-Id'] = PARSE_CONFIG['PARSE_APP_ID']
        request['X-Parse-REST-API-Key'] = PARSE_CONFIG['PARSE_API_KEY']
        request['Content-Type'] = "application/json"

        request.body = pushdata.to_json
        # puts request.body
        response = h.request request
        # puts response
      end
      if followers.blank?
        Notification.create(:user_id => user_id, :reportable => activity.trackable.timeline,:next_reportable=>activity.trackable, :notification => notification, :payload => payload.to_json)
      else
        followers.each do |f|
          Notification.create(:user_id => f.id,:reportable => activity.trackable.timeline,:next_reportable=>activity.trackable, :notification => notification, :payload => payload.to_json)
        end
      end
    end

  end

end