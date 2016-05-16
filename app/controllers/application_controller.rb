require 'tilt/erb'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_filter :authenticate_user_from_token!, :except => :page_not_found

  def page_not_found
    render :json => {:error => "Request not found"}, :status => 404
  end

  private

  def track_activity(trackable, action = params[:action])
    @current_user.activities.create! action: action, trackable: trackable
  end

  protected

  def authenticate_user_from_token!
    if claims and user = User.find_by(external_id: claims[0]['user_id'])
      @current_user = user
    else
      render :json => {:error => "You are not authorized to perform this request."}, :status => 401
    end
  end

  def claims
    auth_header = request.headers['X-Timeline-Authentication'] and
        token = auth_header.split(' ').last and
        ::JsonWebToken.decode(token)
  rescue
    nil
  end

  def jwt_token user
    JsonWebToken.encode('user_id' => user.external_id, 'username' => user.name)
  end

end
