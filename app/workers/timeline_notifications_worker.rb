class TimelineNotificationsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'high'
  sidekiq_options retry: false
  sidekiq_options unique: :until_and_while_executing

  def perform(activity_id)
    notification = nil
    activity = Activity.find_by(:id=>activity_id)
    external_id = activity.trackable.user.external_id
    user_id = activity.trackable.user.id
    user_query = {'__type' => 'Pointer', 'className' => '_User', 'objectId' => external_id}

    if activity.action == 'like'
      notification = "@#{activity.user.name} likes your feedeo ##{activity.trackable.name}."
      payload = {:timeline_id => activity.trackable_id, :name => activity.trackable.name, :action => activity.action}
    elsif activity.action == 'follow'
      notification = "@#{activity.user.name} is now following your feedeo ##{activity.trackable.name}."
      payload = {:timeline_id => activity.trackable_id, :name => activity.trackable.name, :action => activity.action}
    elsif activity.action == 'follow_request'
      notification = "@#{activity.user.name} wants to follow your feedeo ##{activity.trackable.name}."
      payload = {:timeline_id => activity.trackable_id, :name => activity.trackable.name, :action => activity.action}
    elsif activity.action == 'create'
      followers = User.select(:id, :external_id).where(id: Follow.select(:follower_id).where(followable_type: "User", follower_type: "User", followable_id: activity.user.id))
      external_id = {'$in' => followers.map { |u| u.external_id }.to_a.flatten}
      notification = "@#{activity.user.name} created feedeo ##{activity.trackable.name}."
      payload = {:timeline_id => activity.trackable_id, :name => activity.trackable.name, :action => activity.action}
      user_query = {'$inQuery' => {'where' => {'objectId' => external_id}, 'className' => '_User'}}
    end

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
        Notification.create(:user_id => user_id, :reportable => activity.trackable, :notification => notification, :payload => payload.to_json)
      else
        followers.each do |f|
          Notification.create(:user_id => f.id, :reportable => activity.trackable, :notification => notification, :payload => payload.to_json)
        end
      end
    end

  end

end











