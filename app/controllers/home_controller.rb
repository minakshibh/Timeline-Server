class HomeController < ApplicationController

  skip_before_filter :authenticate_user_from_token!

  def index
  end

  def support
  end

  def privacypolicy
  end
end
