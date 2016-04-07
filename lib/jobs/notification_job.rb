require 'erubis'
module Jobs
  class NotificationJob < Struct.new(:notification, :users, :payload)

    def enqueue
    end

    def perform
      send_push_per_user(notification, users, payload)
    end

    def queue_name
      'custom__notification_queue'
    end

    private

    def send_push_per_user(notification, users, payload)
      external_id = {'$in' => users.map { |u| u.external_id }.to_a.flatten}
      user_query = {'$inQuery' => {'where' => {'objectId' => external_id}, 'className' => '_User'}}
      push_data = {:where => {:user => user_query},
                   :data => {:alert => notification, :badge => 'Increment', :sound => 'default', 'content-available' => 1, :payload => payload}}
      send_parse_push(push_data)
      users.each { |user| Notification.create(:user_id => user.id, :notification => notification, :payload => payload.merge!(:user_id=>user.id).to_json) }
    end

    def send_parse_push(push_data)
      uri = URI.parse("https://api.parse.com/1/push")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'
      response = nil

      http.start do |h|
        request = Net::HTTP::Post.new uri.request_uri
        #request['X-Parse-Application-Id'] = "LiynFqjSP5wmP8QfzLQLgm8tGStY3Jt5FeH34lhS"
        #request['X-Parse-REST-API-Key'] = "ZzxcBVYpinitFMF5k7JXmfDLXoBPArNtVFo0ZD58"

        request['X-Parse-Application-Id'] = "Zlos4Gg3l7oIeyfekTgMNrA5ENWoHmyKGuRiM39C"
        request['X-Parse-REST-API-Key'] = "0NZmxMSRfvytkLw05nXEcTpXSAgzP22KW5RpFmpY"
        request['Content-Type'] = "application/json"

        request.body = push_data.to_json
        # puts request.body
        response = h.request request
        # puts response
      end
    end

  end
end