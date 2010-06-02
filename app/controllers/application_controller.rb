class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'
  
  protected
  
  def cassandra
    @cassandra ||= Cassandra.new("Votwitter")
  end
  
  def oauth
    @oauth ||= begin
      conf = File.open(File.join(File.dirname(__FILE__), '..', '..', 'config', 'twitter.yml') ) { |yf| YAML::load( yf ) }
      Twitter::OAuth.new(conf['development']['token'], conf['development']['secret'])
    end
  end
  
  def authenticated? user
    !user['token'].nil? && !user['secret'].nil?
    
  end
end
