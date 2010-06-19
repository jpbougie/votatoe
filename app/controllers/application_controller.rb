require 'twitter_ext'

class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  
  protected
  
  def oauth
    @oauth ||= Twitter.oauth(true)
  end
  
  def twitter
    @twitter ||= user.use_twitter {|twitter| twitter }
  end
  helper_method :twitter
  
  def signed_in?
    user && authenticated?(user)
  end
  
  helper_method :signed_in?
  
  def sign_in profile
    session[:user] = profile.id
    
    user = create_user_if_needed(profile)
    update_tokens(user)
  end
  
  def create_user_if_needed(profile)
    u = User.find_or_initialize_by_twitter_id(session[:user])
    if u.new_record?
      u.username = profile.screen_name
      u.save
    end
    
    u
  end
  
  def update_tokens(user)
    a = Account.find_or_create_by_id(user.id)
    a.token = session[:atoken]
    a.secret = session[:asecret]
    
    a.save
  end
  
  def authenticated? user
    Account.where(:id => user.id).first != nil
  end
  
  def authenticate
    redirect_to new_session_path unless signed_in?
  end
  
  def user
    @user ||= User.find_by_twitter_id(session[:user]) if session[:user]
  end
  helper_method :user
end
