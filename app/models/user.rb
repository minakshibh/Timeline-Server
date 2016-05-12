class User < ActiveRecord::Base
  include ActiveUUID::UUID

  has_many :timelines, dependent: :destroy
  has_many :activities
  has_many :blocks
  has_many :notifications,:dependent=>:destroy
  has_many :comments
  scope :notifications_before_current_timestamp, -> (user, time_stamp) { user.notifications.where('created_at < ?', time_stamp) }
  acts_as_liker
  acts_as_likeable
  acts_as_follower
  acts_as_followable
  acts_as_mentionable


  after_destroy :delete_relations

  def self.search(search)
    # Previous query
    # where('users.name LIKE ?', "%#{search}%")
    # New query added by Insonix
    where('users.name LIKE ? || users.firstname LIKE ? || users.lastname LIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
  end

  def follow_status(object)
    if self.follows?(object) or object == self
      "following"
    else
      if !FollowQueue.where(:follower => self, :followable => object).empty?
        "pending"
      else
        "not following"
      end
    end
  end

  def self.followed_by(current_user)
    where("users.id IN (?)", Follow.users(current_user))
  end

  def self.blocked(current_user)
    where("users.id IN (?)", Block.select(:blockable_id).where(:blockable_type => 'User', :user => current_user))
  end

  def blocked?(object)
    !Block.where(:blockable => object, :user => self).empty?
  end

  # parse actions

  def self.find_by_parse_token(session_token)
    # check session against Parse
    uri = URI.parse("https://api.parse.com/1/users/me")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'

    response = nil

    http.start do |h|
      request = Net::HTTP::Get.new uri.request_uri
      request['X-Parse-Application-Id'] = PARSE_CONFIG['PARSE_APP_ID']
      request['X-Parse-REST-API-Key'] = PARSE_CONFIG['PARSE_API_KEY']
      request['X-Parse-Session-Token'] = session_token
      response = h.request request
    end

    # Check if session is valid
    user = JSON.parse(response.body)

    if user['objectId']
      # Check if user exists
      u_obj = User.find_or_create_by(:external_id => user['objectId']) do |u|
        u.name = user['username']
        u.email = user['email']
      end

      u_obj
    else
      nil
    end
  end

  def self.update_from_parse(objectId)
    # retrieve user from Parse
    uri = URI.parse("https://api.parse.com/1/users/" + objectId)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'

    response = nil

    http.start do |h|
      request = Net::HTTP::Get.new uri.request_uri
      request['X-Parse-Application-Id'] = PARSE_CONFIG['PARSE_APP_ID']
      request['X-Parse-REST-API-Key'] = PARSE_CONFIG['PARSE_API_KEY']

      response = h.request request
    end

    user = JSON.parse(response.body)
    # update with current data from parse
    u_obj = User.find_by_external_id(objectId)
    u_obj.update_columns(email: user['email'], image: user['profile_picture']['url'], bio: user['bio'], firstname: user['firstname'], lastname: user['lastname'], website: user['website'], other: user['other'])
    u_obj
  end

  def parse_profile_image
    # retrieve user from Parse
    uri = URI.parse("https://api.parse.com/1/users/" + self.external_id)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    response = nil

    http.start do |h|
      request = Net::HTTP::Get.new uri.request_uri
      request['X-Parse-Application-Id'] = PARSE_CONFIG['PARSE_APP_ID']
      request['X-Parse-REST-API-Key'] = PARSE_CONFIG['PARSE_API_KEY']

      response = h.request request
    end

    user = JSON.parse(response.body)

    # update with current data from parse
    user['profile_picture']['url']
  end

  def notifications_processing(notifications)
    result = []
    notifications.each do |user_notification|
      user_notification = user_notification.as_json
      username = user_notification['notification'].to_s.split(' ')[0].gsub('@', '')
      user = User.find_by_name(username)
      user_notification.merge!(:username => object_attribute(user, 'name'), :first_name => object_attribute(user, 'firstname'), :last_name => object_attribute(user, 'lastname'), :username_id => object_attribute(user, 'id'), :user_image => object_attribute(user, 'image'))
      result.push(user_notification)
    end
    result
  end

  private

  def delete_relations
    @blocks = Block.where("blocks.blockable_id = ? OR blocks.user_id = ?", self.id, self.id)
    @blocks.destroy_all
    @follow_queues = FollowQueue.where("follow_queues.follower_id = ? OR follow_queues.followable_id = ?", self.id, self.id)
    @follow_queues.destroy_all
  end

  def object_attribute(user, attribute)
    user.send(attribute) rescue ''
  end

end