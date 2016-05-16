require 'erubis'
module Jobs
  class NotificationJob

    def self.perform(notification, external_id, payload)
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
    end

    def self.queue
      'notifications'
    end

  end
end