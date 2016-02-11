class VideoController < ApplicationController

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
      render :json => {:error => @video.errors.full_messages }, :status => 400
    end
  end

  private

  def video_params
    params.permit(:video, :timeline_id, :overlay_text, :overlay_position, :overlay_size, :overlay_color)
  end
end
