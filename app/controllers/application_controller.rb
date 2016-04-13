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
    # puts "=====request_token========#{request.headers['X-Timeline-Authentication']}"
    # puts "=========here=#{::JsonWebToken.decode(request.headers['X-Timeline-Authentication'].split(' ').last)}"
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

  #------------------------ Code to resolve cross domain problem and no access control ----------------------#
  #---------------------------------- Start Code Sniped ----------------------------------------------------#
  def add_allow_credentials_headers
    response.headers['Access-Control-Allow-Origin'] = request.headers['Origin'] || '*'
    response.headers['Access-Control-Allow-Credentials'] = 'true'
  end

  def options
    head :status => 200, :'Access-Control-Allow-Headers' => 'accept, content-type'
  end
  #---------------------------------- End Code Sniped ----------------------------------------------------#


end
