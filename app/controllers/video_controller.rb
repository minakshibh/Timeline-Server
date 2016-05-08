class VideoController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:post_comment, :fetch_comments,:create]
  before_action :check_video_presence, :only => [:post_comment, :fetch_comments, :show]

  def show
    render :json => @video, :status => 200
  end

  def create
    @video = Video.new(video_params)
    if @video.save
      Video.group_alert(@current_user, @video) if @video.timeline.group_timeline
      track_activity @video
      render :json => @video, :status => 200 and return
    else
      render :json => {:error => @video.errors.full_messages}, :status => 400
    end
  end

  # Added by insonix
  def post_comment
    comment = @video.comments.create(:title => params[:title], :comment => params[:comment], :user_id => @current_user.id, :user_image => @current_user.image)
    if comment.valid?
      Video.tagging(@current_user, params[:tag_users], @video, comment) if params[:tag_users].present?
      render :json => {:status_code => 200, :success => 'comment created successfully'}
    else
      render :json => {:status_code => 422, :error => comment.errors.full_messages.to_sentence}
    end
  end

  # Added by insonix
  def fetch_comments
    result = []
    @video.comments.includes(:user).each do |object|
      record = object.as_json
      record.merge!(:username => object_attribute(object.user, 'name'), :payload => {'user_id' => object_attribute(object.user, 'id'), 'external' => object_attribute(object.user, 'external_id'), 'name' => object_attribute(object.user, 'name')}.to_json.to_s)
      result.push(record)
    end
    render :json => {:status_code => 200, :comments_count => result.count, :result => result}
  rescue ActiveRecord::ActiveRecordError, Exception => error
    render :json => {:status_code => 417, :error => error.message}
  end


  private

  def video_params
    params.permit(:video, :timeline_id, :overlay_text, :overlay_position, :overlay_size, :overlay_color)
  end

  # Added by insonix
  def check_video_presence
    @video = Video.find_by_id(params[:id])
    render :json => {:status => 404, :message => 'Moment not found'} and return if @video.blank?
  end

  # Added by insonix
  def object_attribute(user, attribute)
    user.send(attribute) rescue ''
  end

end
