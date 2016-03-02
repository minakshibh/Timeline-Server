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
      comment = video.comments.create(:title => params[:title], :comment => params[:comment], :user_id => @current_user.id, :user_image => user_profile_image)
      if params[:tag_users].present?
        params[:tag_users].split(',').each do |tag_user_id|
          user = User.find_by_id(tag_user_id)
          payload = {:user_id=>user.id,:video_id=>video.id}
          comment.mention!(user)
          # Create Notification
          Notification.create(:user_id => user.id, :notification =>"@#{@current_user.name} mention you in moment ##{video.timeline.name} comment", :payload => payload.to_json)
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
      video = Video.find_by_id(params[:id])
      video.comments.includes(:user).each do |object|
        record = object.as_json
        record[:username] = object.user.name rescue ''
        user_id = object.user.id rescue ''
        external_id =  object.user.external_id rescue ''
        name = object.user.name rescue ''
        record[:payload] = {'user_id'=>user_id,'external'=>external_id,'name'=>name}.to_json.to_s
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
