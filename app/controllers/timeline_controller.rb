class TimelineController < ApplicationController
  #Added by insonix
  before_action :set_timeline_instance, :only => [:index, :me, :user, :following, :trending]
  before_action :check_timeline_presence,:only => [:post_comment,:fetch_comments]
  skip_before_filter :authenticate_user_from_token!, :only => :webview
  skip_before_action :verify_authenticity_token, :only => [:post_comment, :fetch_comments]
  before_action :set_timeline, :except => [:index, :me, :user, :create, :create_group_timeline, :destroy, :following, :trending, :unfollow, :block, :unblock, :all_followers, :webview, :blocked]

  # views

  def index
    ##--------------------------------- Initial Code ------------------------------------##
    # @timelines = Timeline.public_or_own(@current_user).order(updated_at: :desc).limit(25)
    ##-----------------------------------------------------------------------------------##

    ##----------------------------- Modified Code (By Insonix) --------------------------##
    Timeline.public_or_own(@current_user).limit(25).each { |timeline| @timelines.push(timeline) }
    GroupTimeline.includes(:timeline).public_or_own(@current_user).limit(25).each { |group_timeline| @timelines.push(group_timeline.timeline) }
    @timelines.sort_by! { |record| record.updated_at }.reverse!
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
    GroupTimeline.includes(:timeline).all.each { |record| record.participants.each { |participant| @timelines.push(record.timeline) if participant.to_s.gsub('-', '').eql?(@current_user.id.to_s.gsub('-', '')) } }
    @timelines.sort_by! { |record| record.updated_at }.reverse!
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
    GroupTimeline.includes(:timeline).public_or_own(@current_user).each { |record| record.participants.each { |participant| @timelines.push(record.timeline) if participant.to_s.gsub('-', '').eql?(params[:user_id].to_s.gsub('-', '')) } }
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
    GroupTimeline.includes(:timeline).public_or_own(@current_user).each { |record| record.participants.each { |participant| @timelines.push(record.timeline) if participant.to_s.gsub('-', '').eql?(@current_user.id.to_s.gsub('-', '')) } }
    @timelines.sort_by! { |record| [record.updated_at, record.likers_count, record.followers_count] }.reverse!
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
    # Modify by insonix
    participants = set_group_timeline_participants(params) if params[:group_timeline].to_s.eql?('1')
    if @timeline.save
      track_activity @timeline
      @timeline.group_timelines.create(:participants => participants, :admin_id => @current_user.id, :admin_name => @current_user.name) if params[:group_timeline].to_s.eql?('1')
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
      user_profile_image = @current_user.parse_profile_image rescue ''
      comment = @timeline.comments.create(:title => params[:title], :comment => params[:comment], :user_id => @current_user.id, :user_image => user_profile_image)
      if params[:tag_users].present?
        params[:tag_users].split(',').each do |tag_user_id|
          user = User.find_by_id(tag_user_id)
          payload = {:user_id => user.id, :timeline_id => @timeline.id, :name => @timeline.name}
          comment.mention!(user)
          # Create Notification
          Notification.create(:user_id => user.id, :notification => "@#{@current_user.name} mention you in timeline ##{@timeline.name} comment", :payload => payload.to_json)
        end
      end
      render :json => {:status_code => 200, :success => 'comment created successfully'}
    rescue ActiveRecord::ActiveRecordError, Exception => error
      render :json => {:status_code => 417, :error => error.message}
    end
  end

  # Added by insonix
  def fetch_comments
    begin
      result = []
      @timeline.comments.includes(:user).each do |object|
        record = object.as_json
        record[:username] = object.user.name rescue ''
        user_id = object.user.id rescue ''
        external_id = object.user.external_id rescue ''
        name = object.user.name rescue ''
        record[:payload] = {'user_id' => user_id, 'external' => external_id, 'name' => name}.to_json.to_s
        result.push(record)
      end
      render :json => {:status_code => 200, :comments_count => result.count, :result => result}
    rescue ActiveRecord::ActiveRecordError, Exception => error
      render :json => {:status_code => 417, :error => error.message}
    end
  end

  private

  def timeline_params
    params.permit(:name, :group_timeline, :description)
  end

  def group_timeline_params
    params.permit(params[:name], params[:description], params[:owner])
  end

  def set_timeline
    @timeline = Timeline.public_or_own(@current_user).find params[:id]
  end

  def set_group_timeline_participants(params)
    participants = []
    params[:participants].split(',').each do |member|
      participants.push(member)
    end
    participants
  end

  def set_timeline_instance
    @timelines = []
  end
  # Added by insonix
  def check_timeline_presence
    @timeline = Timeline.find_by_id(params[:id])
    render :json => {:status=>404,:message=>'Timeline not found'} and return if @timeline.blank?

  end

end
