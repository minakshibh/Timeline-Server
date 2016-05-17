class UserNotificationsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'high'

  def perform(activity_id)
    activity = Activity.find_by_id(activity_id)
    followers = nil
    external_id = activity.trackable.external_id
    user_id = activity.trackable.id
    user_query = {'__type' => 'Pointer', 'className' => '_User', 'objectId' => external_id}
    if activity.action == 'like'
      notification = "@#{activity.user.name} likes your profile."
      payload = {:user_id => activity.user.id, :name => activity.user.name, :external => activity.user.external_id, :action => activity.action}
    elsif activity.action == 'follow'
      notification = "@#{activity.user.name} is now following you."
      payload = {:user_id => activity.user.id, :name => activity.user.name, :external => activity.user.external_id, :action => activity.action}
    elsif activity.action == 'follow_request'
      notification = "@#{activity.user.name} wants to follow you."
      payload = {:user_id => activity.user.id, :name => activity.user.name, :external => activity.user.external_id, :action => activity.action}
    elsif activity.action == 'follow_accept'
      notification = "@#{activity.user.name} accepted your following request."
      payload = {:user_id => activity.user.id, :name => activity.user.name, :external => activity.user.external_id, :action => activity.action}
    end

    pushdata = {:where => {:user => user_query},
                :data => {:alert => notification, :badge => 'Increment', :sound => 'default', 'content-available' => 1, :payload => payload}}

    # send REST call to Parse if we have a notification
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
    if !followers
      Notification.create(:user_id => user_id, :reportable => activity.trackable, :notification => notification, :payload => payload.to_json)
    else
      followers.each do |f|
        Notification.create(:user_id => f.id, :reportable => activity.trackable, :notification => notification, :payload => payload.to_json)
      end
    end

  end

end