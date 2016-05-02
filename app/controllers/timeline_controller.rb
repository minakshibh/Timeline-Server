class TimelineController < ApplicationController
  #Added by insonix
  before_action :set_timeline_instance, :only => [:index, :me, :user, :following, :trending]
  before_action :check_timeline_presence, :only => [:post_comment, :fetch_comments]
  skip_before_filter :authenticate_user_from_token!, :only => :webview
  skip_before_action :verify_authenticity_token, :only => [:post_comment, :fetch_comments]
  before_action :set_timeline, :except => [:index, :me, :user, :create, :destroy, :following, :trending, :unfollow, :block, :unblock, :all_followers, :webview, :blocked]
  # views

  def index
    ##--------------------------------- Initial Code ------------------------------------##
    # @timelines = Timeline.public_or_own(@current_user).order(updated_at: :desc).limit(25)
    ##-----------------------------------------------------------------------------------##

    ##----------------------------- Modified Code (By Insonix) --------------------------##
    Timeline.public_or_own(@current_user).limit(25).each { |timeline| @timelines.push(timeline) }
    GroupTimeline.includes(:timeline).public_or_own(@current_user).limit(25).each { |group_timeline| @timelines.push(group_timeline.timeline) }
    @timelines.compact.sort_by! { |record| record.updated_at }.reverse!
    ##-----------------------------------------------------------------------------------##
  end

  def show
  end

  def show_videos
  end

  def me
    ##--------------------------------- Initial Code ------------------------------------##
    # @timelines = Timeline.where(:user_id => @current_user.id).order(updated_at: :desc)
    # render :index
    ##-----------------------------------------------------------------------------------##

    ##----------------------------- Modified Code (By Insonix) --------------------------##
    Timeline.where(:user_id => @current_user.id).each { |timeline| @timelines.push(timeline) }
    GroupTimeline.includes(:timeline).all.each { |record| record.participants.each { |participant| @timelines.push(record.timeline) if participant.to_s.eql?(@current_user.id.to_s) } }
    @timelines.compact.sort_by! { |record| record.updated_at }.reverse!
    render :index
    ##-----------------------------------------------------------------------------------##
  end

  def user
    ##--------------------------------- Initial Code ------------------------------------##
    # @timelines = Timeline.public_or_own(@current_user).where(:user_id => params[:user_id])
    # render :index
    ##-----------------------------------------------------------------------------------##

    ##----------------------------- Modified Code (By Insonix) --------------------------##
    Timeline.public_or_own(@current_user).where(:user_id => params[:user_id]).each { |timeline| @timelines.push(timeline) }
    GroupTimeline.includes(:timeline).public_or_own(@current_user).each { |record| record.participants.each { |participant| @timelines.push(record.timeline) if participant.to_s.eql?(params[:user_id].to_s) } }
    render :index
    ##-----------------------------------------------------------------------------------##
  end

  def following
    @timelines = Timeline.followed_by(@current_user).order(updated_at: :desc)
    render :index
  end

  def trending
    ##--------------------------------- Initial Code ------------------------------------##
    # @timelines = Timeline.public_or_own(@current_user).includes(:videos).where.not(videos: { id: nil }).order(updated_at: :desc, likers_count: :desc, followers_count: :desc).limit(25)
    # render :index
    ##-----------------------------------------------------------------------------------##

    ##----------------------------- Modified Code (By Insonix) --------------------------##
    Timeline.public_or_own(@current_user).includes(:videos).where.not(videos: {id: nil}).limit(25).each { |timeline| @timelines.push(timeline) }
    GroupTimeline.includes(:timeline).public_or_own(@current_user).each { |record| record.participants.each { |participant| @timelines.push(record.timeline) if participant.to_s.eql?(@current_user.id.to_s) } }
    @timelines.compact.sort_by! { |record| [record.updated_at, record.likers_count, record.followers_count] }.reverse!
    render :index
    ##-----------------------------------------------------------------------------------##
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
    @timeline.group_timeline = set_timeline_type(params)
    # Modify by insonix
    participants = set_group_timeline_participants(params) if params[:group_timeline].to_s.eql?('1')
    render :json => {:status_code => 404, :message => 'participant list can not be blank'} and return if participants.blank? && params[:group_timeline].to_s.eql?('1')
    if @timeline.save
      track_activity @timeline
      @timeline.group_timelines.create(:participants => participants, :user_id => @current_user.id, :user_name => @current_user.name) if params[:group_timeline].to_s.eql?('1')
      render :show
    else
      render :json => {:error => @timeline.errors.full_messages}, :status => 400 and return
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
    comment = @timeline.comments.create(:title => params[:title], :comment => params[:comment], :user_id => @current_user.id, :user_image => @current_user.image)
    if comment.valid?
      Timeline.tagging(@current_user, params[:tag_users], @timeline, comment) if params[:tag_users].present?
      render :json => {:status_code => 200, :success => 'comment created successfully'}
    else
      render :json => {:status_code => 422, :error => comment.errors.full_messages.to_sentence}
    end
  end

  # Added by insonix
  def fetch_comments
    result = []
    @timeline.comments.includes(:user).each do |object|
      record = object.as_json
      record.merge!(:username => object_attribute(object.user, 'name'), :payload => {'user_id' => object_attribute(object.user, 'id'), 'external' => object_attribute(object.user, 'external_id'), 'name' => object_attribute(object.user, 'name')}.to_json.to_s)
      result.push(record)
    end
    render :json => {:status_code => 200, :comments_count => result.count, :result => result}
  rescue ActiveRecord::ActiveRecordError, Exception => error
    render :json => {:status_code => 417, :error => error.message}
  end

  private

  def timeline_params
    params.permit(:name, :group_timeline, :description)
  end

  def set_timeline
    @timeline = Timeline.public_or_own(@current_user).find params[:id]
  end

  def set_group_timeline_participants(params)
    participants = []
    if params[:participants].blank?
      nil
    else
      params[:participants].split(',').each do |member|
        participants.push(member)
      end
      participants
    end
  end

  def set_timeline_instance
    @timelines = []
  end

  # Added by insonix
  def check_timeline_presence
    @timeline = Timeline.find_by_id(params[:id])
    render :json => {:status => 404, :message => 'Feedeo not found'} and return if @timeline.blank?
  end

  def set_timeline_type(params)
    params[:group_timeline].present? && params[:group_timeline].to_s.eql?('1') ? 1 : 0
  end

  def object_attribute(user, attribute)
    user.send(attribute) rescue ''
  end

end
