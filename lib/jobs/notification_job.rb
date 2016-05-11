require 'erubis'
module Jobs
  class NotificationJob < Struct.new(:notification, :users, :payload)

    def perform
      external_id = {'$in' => users.map { |u| u.external_id }.to_a.flatten}
      user_query = {'$inQuery' => {'where' => {'objectId' => external_id}, 'className' => '_User'}}
      push_data = {:where => {:user => user_query},
                   :data => {:alert => notification, :badge => 'Increment', :sound => 'default', 'content-available' => 1, :payload => payload}}
      #sending push to parse server

      uri = URI.parse("https://api.parse.com/1/push")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      response = nil

      http.start do |h|
        request = Net::HTTP::Post.new uri.request_uri
        request['X-Parse-Application-Id'] = PARSE_CONFIG['PARSE_APP_ID']
        request['X-Parse-REST-API-Key'] = PARSE_CONFIG['PARSE_API_KEY']
        request['Content-Type'] = "application/json"

        request.body = push_data.to_json
        # puts request.body
        response = h.request request
        # puts response
      end
      # create user notification into db
      users.each { |user| Notification.create(:user_id => user.id, :notification => notification, :payload => payload.merge!(:user_id => user.id).to_json) }
    end

    def destroy_failed_jobs?
      false
    end

    def queue_name
      'notifications_alert'
    end

  end
end