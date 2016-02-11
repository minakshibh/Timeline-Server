class Activity < ActiveRecord::Base
  include ActiveUUID::UUID

  belongs_to :user
  belongs_to :trackable, :polymorphic => true

  after_save :send_notification

  private

  def send_notification

    notification = nil

    if self.trackable_type == 'Timeline'
      external_id = self.trackable.user.external_id
      user_id = self.trackable.user.id
      user_query = {'__type' => 'Pointer', 'className' => '_User', 'objectId' => external_id}

      if self.action == 'like'
        notification = "@#{self.user.name} likes your timeline ##{self.trackable.name}."
        payload = {:timeline_id => self.trackable_id, :name => self.trackable.name, :action => self.action}
      elsif self.action == 'follow'
        notification = "@#{self.user.name} is now following your timeline ##{self.trackable.name}."
        payload = {:timeline_id => self.trackable_id, :name => self.trackable.name, :action => self.action}
      elsif self.action == 'follow_request'
        notification = "@#{self.user.name} wants to follow your timeline ##{self.trackable.name}."
        payload = {:timeline_id => self.trackable_id, :name => self.trackable.name, :action => self.action}
      elsif self.action == 'create'
        followers = User.select(:id, :external_id).where(id: Follow.select(:follower_id).where(followable_type: "User", follower_type: "User", followable_id: self.user.id))
        external_id = { '$in' => followers.map {|u| u.external_id }.to_a.flatten }
        notification = "@#{self.user.name} created timeline ##{self.trackable.name}."
        payload = {:timeline_id => self.trackable_id, :name => self.trackable.name, :action => self.action}
        user_query = {'$inQuery' => {'where' => {'objectId' => external_id}, 'className' => '_User'}}
      end

    elsif self.trackable_type == 'User'
      external_id = self.trackable.external_id
      user_id = self.trackable.id
      user_query = {'__type' => 'Pointer', 'className' => '_User', 'objectId' => external_id}

      if self.action == 'like'
        notification = "@#{self.user.name} likes your profile."
        payload = {:user_id => self.user.id, :name => self.user.name, :external => self.user.external_id, :action => self.action}
      elsif self.action == 'follow'
        notification = "@#{self.user.name} is now following you."
        payload = {:user_id => self.user.id, :name => self.user.name, :external => self.user.external_id, :action => self.action}
      elsif self.action == 'follow_request'
        notification = "@#{self.user.name} wants to follow you."
        payload = {:user_id => self.user.id, :name => self.user.name, :external => self.user.external_id, :action => self.action}
      elsif self.action == 'follow_accept'
        notification = "@#{self.user.name} accepted your following request."
        payload = {:user_id => self.user.id, :name => self.user.name, :external => self.user.external_id, :action => self.action}
      end
    elsif self.trackable_type == 'Video'
      followers = User.select(:id, :external_id).where(id: Follow.select(:follower_id).where(followable_type: "Timeline", follower_type: "User", followable_id: self.trackable.timeline.id))
      external_id = { '$in' => followers.map {|u| u.external_id }.to_a.flatten }
      notification = "@#{self.user.name} added a moment to ##{self.trackable.timeline.name}."
      payload = {:timeline_id => self.trackable.timeline.id,:video_id => self.trackable_id, :name => self.trackable.timeline.name, :action => self.action}
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
        request['X-Parse-Application-Id'] = "LiynFqjSP5wmP8QfzLQLgm8tGStY3Jt5FeH34lhS"
        request['X-Parse-REST-API-Key'] = "ZzxcBVYpinitFMF5k7JXmfDLXoBPArNtVFo0ZD58"
        request['Content-Type'] = "application/json"

        request.body = pushdata.to_json
        # puts request.body

        response = h.request request
        # puts response
      end

      if !followers
        Notification.create(:user_id => user_id, :notification => notification, :payload => payload.to_json)
      else
        followers.each do |f|
          Notification.create(:user_id => f.id, :notification => notification, :payload => payload.to_json)
        end
      end
    end
  end
  handle_asynchronously :send_notification, :queue => 'notifications'
end
