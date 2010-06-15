class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  
  protected
  
  def twitter_down
    render :text => "twitter is having difficulties right now"
  end
    
  def oauth
    @oauth ||= begin
      conf = File.open(File.join(File.dirname(__FILE__), '..', '..', 'config', 'twitter.yml') ) { |yf| YAML::load( yf ) }
      Twitter::OAuth.new(conf[Rails.env]['token'], conf[Rails.env]['secret'], :sign_in => true)
    end
  end
  
  def twitter
    @twitter ||= begin
        oauth.authorize_from_access(user['token'], user['secret'])
        Twitter::Base.new(oauth)
      end
  end
  helper_method :twitter
  
  def user_profile
    
  end
  
  def signed_in?
    user && authenticated?(user)
  end
  helper_method :signed_in?
  
  def sign_in profile
    session[:user] = profile.id
  end
  
  def authenticated? user
  end
  
  def authenticate
    redirect_to new_session_path unless signed_in?
  end
  
  def user
    @user ||= cassandra.get(:User, session[:user].to_s) if session[:user]
    @user = nil if @user == {}
    @user
  end
  
end
