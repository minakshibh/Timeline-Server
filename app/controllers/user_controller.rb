class UserController < ApplicationController

  skip_before_filter :authenticate_user_from_token!, :only => [:get_token, :webview]

  before_action :set_user, :only => [:show, :like, :unlike, :follow, :unfollow, :block, :unblock, :accept, :decline, :user_followers, :likers]

  # views

  def index
    @users = User.all
  end

  def show
  end

  def me
    @pending_followers = FollowQueue.pending(@current_user).count
    @user = @current_user
  end

  def follow_queue
    @users = FollowQueue.pending(@current_user)
    render :index
  end

  def following
    @users = User.followed_by(@current_user)
    render :index
  end

  def followers
    @users = @current_user.followers_relation(User)
    render :index
  end

  def user_followers
    @users = @user.followers_relation(User)
    render :index
  end

  def likers
    @users = @user.likers_relation(User)
    render :index
  end

  def blocked
    if @users = User.blocked(@current_user)
      render :index
    else
      render :json => {:results => "nothing found"}, :status => 200
    end
  end

  def notifications
    @notifications = Notification.where(:user => @current_user).where('notifications.created_at > ?', DateTime.parse(params[:date]).to_s(:db))
    render :json => @notifications.to_json, :status => 200
  end

  def webview
    @user = User.where(:name => params[:user_name]).first
  end

  # actions

  def update
    @user = User.update_from_parse(@current_user.external_id)
    render :json => @user.to_json, :status => 200
  end

  def set_settings
    if params[:timelines_public]
      @current_user.update(timelines_public: params[:timelines_public])
      render :json => {:success => @current_user.timelines_public}, :status => 200
    elsif params[:approve_followers]
      @current_user.update(approve_followers: params[:approve_followers])
      render :json => {:success => @current_user.approve_followers}, :status => 200
    end
  end

  def increment_timelines
    if @current_user.increment!(:allowed_timelines_count, by = 1)
      render :json => {:success => @current_user.allowed_timelines_count}, :status => 200
    end
  end

  def like
    @current_user.like!(@user)
    track_activity @user
    render :json => {:likes => @user.likers(User).count}, :status => 200
  end

  def unlike
    @current_user.unlike!(@user)
    track_activity @user
    render :json => {:likes => @user.likers(User).count}, :status => 200
  end

  def follow
    if @user.approve_followers?
      @queue = FollowQueue.create(
          :follower_id => @current_user.id,
          :followable_id => @user.id,
          :follower_type => "User",
          :followable_type => "User"
      )
      track_activity @user, "follow_request"
      render :json => {:state => "pending"}, :status => 200
    else
      if @current_user.follow!(@user)
        track_activity @user
        render :json => {:followers => @user.followers(User).count, :state => "success"}, :status => 200
      else
        render :json => {:state => "following"}, :status => 200
      end
    end
  end

  def unfollow
    if @current_user.unfollow!(@user)
      track_activity @user
      render :json => {:followers => @user.followers(User).count, :state => "success"}, :status => 200
    elsif @user.approve_followers? && FollowQueue.where(:follower => @current_user, :followable => @user).count > 0
      FollowQueue.where(:follower => @current_user, :followable => @user).destroy_all
      track_activity @user, "chancel_follow_request"
      render :json => {:followers => @user.followers(User).count, :state => "success"}, :status => 200
    else
      render :json => {:state => "not following"}, :status => 200
    end
  end

  def accept
    if @queue = FollowQueue.where(:follower_id => params[:id], :followable => @current_user).first
      if @user.follow!(@current_user)
        @queue.destroy
        track_activity @user, "follow_accept"
        render :json => {:followers => @user.followers(User).count, :state => "success"}, :status => 200
      else
        render :json => {:state => "following"}, :status => 200
      end
    else
      render :json => {:state => "no request found"}, :status => 400
    end
  end

  def decline
    if @queue = FollowQueue.where(:follower_id => params[:id], :followable => @current_user).first
      if @queue.destroy
        track_activity @user, "follow_decline"
        render :json => {:state => "success"}, :status => 200
      end
    else
      render :json => {:state => "no request found"}, :status => 400
    end
  end

  def block
    if @current_user.blocks.find_by(blockable: @user)
      render :json => {:state => "blocked"}, :status => 200
    else
      @current_user.blocks.create(blockable: @user)
      track_activity @user
      render :json => {:state => "success"}, :status => 200
    end
  end

  def unblock
    if block = @current_user.blocks.find_by(blockable: @user)
      block.destroy
      track_activity @user
      render :json => {:state => "success"}, :status => 200
    else
      render :json => {:state => "not blocked"}, :status => 200
    end
  end

  # Added by Insonix
  def my_followers
    begin
      followers = @current_user.followers_relation(User)
      render :json => {:status_code => 200, :followers_count => followers.count, :result => followers}
    rescue Exception => error
      render :json => {:status_code => 417, :error => error.message}
    end
  end

  def destroy
    if @current_user.delay.destroy
      render :json => {:state => "success"}, :status => 200
    else
      render :json => {:state => "something went wrong"}, :status => 200
    end
  end

  def get_token
    if request.headers['X-Parse-Session-Token'] and
        @user = User.find_by_parse_token(request.headers['X-Parse-Session-Token']) and
        @auth_token = jwt_token(@user)
      @pending_followers = FollowQueue.pending(@user).count
      render :me
    else
      render :json => {:error => "Error generating token."}, :status => 401
    end
  end

  # This is new notification API
  def timeline_notifications
    page_id = params[:page_id].to_i
    time_stamp = DateTime.parse(params[:date]).to_s(:db)
    notifications = User.notifications_before_current_timestamp(@current_user, time_stamp)
    notifications_count = notifications.count
    result = @current_user.notifications_processing(notifications.limit(30).offset(page_id))
    render :json => {:result => result, :status_code => 200, :page_id => (notifications_count - (page_id+30)) > 0 ? page_id+30 : nil}
  rescue ActiveRecord::ActiveRecordError, Exception => error
    render :json => {:error => error.message, :status_code => 417}
  end

  private

  def user_params
    params.permit(:timelines_public, :approve_followers)
  end

  def set_user
    @user = User.find params[:id]
  end

end
