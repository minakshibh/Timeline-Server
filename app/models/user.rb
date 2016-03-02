class User < ActiveRecord::Base
  include ActiveUUID::UUID

  has_many :timelines, dependent: :destroy
  has_many :activities
  has_many :blocks
  has_many :notifications
  has_many :comments
  scope :notifications_before_current_timestamp, -> (user, time_stamp) { user.notifications.where('created_at < ?', time_stamp) }

  acts_as_liker
  acts_as_likeable
  acts_as_follower
  acts_as_followable

  after_destroy :delete_relations

  def self.search(search)
    where('users.name LIKE ?', "%#{search}%")
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
      request['X-Parse-Application-Id'] = "LiynFqjSP5wmP8QfzLQLgm8tGStY3Jt5FeH34lhS"
      request['X-Parse-REST-API-Key'] = "ZzxcBVYpinitFMF5k7JXmfDLXoBPArNtVFo0ZD58"
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

  # Add user_image by insonix
  def self.update_from_parse(objectId)
    # retrieve user from Parse
    uri = URI.parse("https://api.parse.com/1/users/" + objectId)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    response = nil

    http.start do |h|
      request = Net::HTTP::Get.new uri.request_uri
      request['X-Parse-Application-Id'] = "LiynFqjSP5wmP8QfzLQLgm8tGStY3Jt5FeH34lhS"
      request['X-Parse-REST-API-Key'] = "ZzxcBVYpinitFMF5k7JXmfDLXoBPArNtVFo0ZD58"

      response = h.request request
    end

    user = JSON.parse(response.body)

    user_profile_image = user['profile_picture']['url'] rescue ''
#added new fields in
    user_profile_bio = user['bio'] rescue ''
    user_profile_firstname = user['firstname'] rescue ''
    user_profile_lastname = user['lastname'] rescue ''
    user_profile_website = user['website'] rescue ''
    user_profile_other = user['other'] rescue ''

    # update with current data from parse
    u_obj = User.find_by_external_id(objectId)
    Rails.logger.info "=======user_image=#{user_profile_image}"

    u_obj.update_columns(email: user['email'], image: user_profile_image, bio: user_profile_bio, firstname: user_profile_firstname, lastname: user_profile_lastname ,website: user_profile_website, other: user_profile_other)
    #u_obj.update_columns(email: user['email'], image: user_profile_image, bio:user_profile_bio, )

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
      request['X-Parse-Application-Id'] = "LiynFqjSP5wmP8QfzLQLgm8tGStY3Jt5FeH34lhS"
      request['X-Parse-REST-API-Key'] = "ZzxcBVYpinitFMF5k7JXmfDLXoBPArNtVFo0ZD58"

      response = h.request request
    end

    user = JSON.parse(response.body)

    # update with current data from parse
    user['profile_picture']['url']
  end

  private

  def delete_relations
    @blocks = Block.where("blocks.blockable_id = ? OR blocks.user_id = ?", self.id, self.id)
    @blocks.destroy_all
    @follow_queues = FollowQueue.where("follow_queues.follower_id = ? OR follow_queues.followable_id = ?", self.id, self.id)
    @follow_queues.destroy_all
  end

end
