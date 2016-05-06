class SearchController < ApplicationController

  # views

  def index
    if params[:q][0] == '@'
      @results = User.search(params[:q][1..-1]).limit(20)
    elsif params[:q][0] == '#'
      @results = Timeline.public_or_own(@current_user).search(params[:q][1..-1]).limit(20)
    else
      users = User.search(params[:q]).limit(20)
      timelines = Timeline.public_or_own(@current_user).search(params[:q]).limit(20)
      @results = users + timelines
    end
    render :json => @results.to_json, :status => 200
  end

end
