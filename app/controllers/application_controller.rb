class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  
  protected
  
  def cassandra
    @cassandra ||= Cassandra.new("Votwitter", "127.0.0.1:9160", :timeout => 10000)
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
    
    create_user_if_needed(profile)
  end
  
  def authenticated? user
    !user['token'].nil? && !user['secret'].nil?
  end
  
  def authenticate
    redirect_to new_session_path unless signed_in?
  end
  
  def user
    @user ||= cassandra.get(:User, session[:user].to_s) if session[:user]
    @user = nil if @user == {}
    @user
  end
  
  def create_user_if_needed(profile)
    unless user
      cassandra.insert(:User, session[:user].to_s, {'token' => session['atoken'], 'secret' => session['asecret']})
    end
  end
end
