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
  
  def signed_in?
    user && authenticated?(user)
  end
  
  def sign_in profile
    session[:user] = profile.id
  end
  
  def authenticated? user
    !user['token'].nil? && !user['secret'].nil?
  end
  
  def authenticate
    redirect_to new_session_path unless signed_in?
  end
  
  def user
    @user ||= cassandra.get(:User, session[:user].to_s) if session[:user]
  end
end
