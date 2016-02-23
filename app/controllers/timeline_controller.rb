class TimelineController < ApplicationController

  skip_before_filter :authenticate_user_from_token!, :only => :webview
  skip_before_action :verify_authenticity_token, :only => [:post_comment, :fetch_comments]
  before_action :set_timeline, :except => [:index, :me, :user, :create, :destroy, :following, :trending, :unfollow, :block, :unblock, :all_followers, :webview, :blocked]

  # views

  def index
    @timelines = Timeline.public_or_own(@current_user).order(updated_at: :desc).limit(25)
  end

  def show
  end

  def show_videos
  end

  def me
    @timelines = Timeline.where(:user_id => @current_user.id).order(updated_at: :desc)
    render :index
  end

  def user
    @timelines = Timeline.public_or_own(@current_user).where(:user_id => params[:user_id])
    render :index
  end

  def following
    @timelines = Timeline.followed_by(@current_user).order(updated_at: :desc)
    render :index
  end

  def trending
    @timelines = Timeline.public_or_own(@current_user).includes(:videos).where.not(videos: {id: nil}).order(updated_at: :desc, likers_count: :desc, followers_count: :desc).limit(25)
    render :index
  end

  def followers
    @users = @timeline.followers_relation(User)
    render "user/index"
  end

  def likers
    @users = @timeline.likers_relation(User)
    render "user/index"
  end

  def all_followers # move to model!!
    @users = User.where("users.id IN(?)", Follow.select(:follower_id).where("follows.followable_id IN (?)", Timeline.select(:id).where(user: @current_user)))
    render "user/index"
  end

  def blocked
    if @timelines = Timeline.blocked(@current_user)
      render :index
    else
      render :json => {:results => "nothing found"}, :status => 200
    end
  end

  def webview
    @timeline = Timeline.where(:name => params[:timeline_name], :user => User.find_by(:name => params[:user_name])).first
  end

  # actions

  def like
    @current_user.like!(@timeline)
    track_activity @timeline
    render :json => {:likes => @timeline.likers(User).count}, :status => 200
  end

  def unlike
    @current_user.unlike!(@timeline)
    track_activity @timeline
    render :json => {:likes => @timeline.likers(User).count}, :status => 200
  end

  def follow
=begin
     if @timeline.user.approve_followers?
      @queue = FollowQueue.create(
          :follower_id => @current_user.id,
          :followable_id => @timeline.id,
          :follower_type => "User",
          :followable_type => "Timeline"
      )
      track_activity @timeline, "follow_request"
      render :json => {:state => "pending"}, :status => 200
    else
=end
    if @current_user.follow!(@timeline)
      track_activity @timeline
      render :json => {:followers => @timeline.followers(User).count, :state => "success"}, :status => 200
    else
      render :json => {:state => "following"}, :status => 200
    end
#    end
  end

  def unfollow
    @timeline = Timeline.find params[:id]
    if @current_user.unfollow!(@timeline)
      track_activity @timeline
      render :json => {:followers => @timeline.followers(User).count, :state => "success"}, :status => 200
    else
      render :json => {:state => "not following"}, :status => 200
    end
  end

  def block
    @timeline = Timeline.find params[:id]
    if @current_user.blocks.find_by(blockable: @timeline)
      render :json => {:state => "blocked"}, :status => 200
    else
      @current_user.blocks.create(blockable: @timeline)
      track_activity @timeline
      render :json => {:state => "success"}, :status => 200
    end
  end

  def unblock
    @timeline = Timeline.find params[:id]
    if block = @current_user.blocks.find_by(blockable: @timeline)
      block.destroy
      track_activity @timeline
      render :json => {:state => "success"}, :status => 200
    else
      render :json => {:state => "not blocked"}, :status => 200
    end
  end

  def create
    @timeline = Timeline.new(timeline_params)
    @timeline.user_id = @current_user.id

    if @timeline.save
      track_activity @timeline
      render :show
    else
      render :json => {:error => @timeline.errors.full_messages}, :status => 400
    end
  end

  def destroy
    @timeline = Timeline.find(params[:id])
    if @timeline.destroy
      track_activity @timeline
      render :json => {:success => true}, :status => 200
    else
      render :json => {:error => @timeline.errors.full_messages}, :status => 400
    end
  end

  # Added by insonix
  def post_comment
    begin
      timeline = Timeline.find_by_id(params[:id])
      user = User.find_by_id(params[:user_id])
      user_profile_image = @current_user.parse_profile_image rescue ''
      timeline.comments.create(:title => params[:title], :comment => params[:comment], :user_id => user.id, :user_image => user_profile_image)
      render :json => {:status_code => 200, :success => 'comment created successfully'}
    rescue ActiveRecord::ActiveRecordError, Exception => error
      render :json => {:status_code => 417, :error => error.message}
    end
  end

  # Added by insonix
  def fetch_comments
    begin
      result = []
      timeline = Timeline.find_by_id(params[:id])
      timeline.comments.includes(:user).each do |object|
        record = object.as_json
        record[:username] = object.user.name
        result.push(record)
      end
      render :json => {:status_code => 200, :comments_count => result.count, :result => result}
    rescue ActiveRecord::ActiveRecordError, Exception => error
      render :json => {:status_code => 417, :error => error.message}
    end
  end

  private

  def timeline_params
    params.permit(:name)
  end

  def set_timeline
    @timeline = Timeline.public_or_own(@current_user).find params[:id]
  end

end
