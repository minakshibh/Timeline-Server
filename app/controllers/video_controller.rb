class VideoController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:post_comment, :fetch_comments]

  def show
    @video = Video.find params[:id]
    render :json => @video, :status => 200
  end

  def create
    @video = Video.new(video_params)

    if @video.save
      track_activity @video
      render :json => @video, :status => 200
    else
      render :json => {:error => @video.errors.full_messages}, :status => 400
    end
  end

  # Added by insonix
  def post_comment
    begin
      video = Video.find_by_id(params[:id])
      user_profile_image = @current_user.parse_profile_image rescue ''
      video.comments.create(:title => params[:title], :comment => params[:comment], :user_id => @current_user.id, :user_image => user_profile_image)
      render :json => {:status_code => 200, :success => 'comment created successfully'}
    rescue ActiveRecord::ActiveRecordError, Exception => error
      render :json => {:status_code => 417, :error => error.message}
    end
  end

  # Added by insonix
  def fetch_comments
    begin
      result = []
      video = Video.find_by_id(params[:id])
      video.comments.includes(:user).each do |object|
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

  def video_params
    params.permit(:video, :timeline_id, :overlay_text, :overlay_position, :overlay_size, :overlay_color)
  end
end
