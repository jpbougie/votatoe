class Twitter
  def with_access(token, secret)
    conf = File.open(File.join(File.dirname(__FILE__), '..', '..', 'config', 'twitter.yml') ) { |yf| YAML::load( yf ) }
    
    oauth = Twitter::OAuth.new(conf[Rails.env]['token'], conf[Rails.env]['secret'], :sign_in => true)
    oauth.authorize_from_access(token, secret)
    
    yield Twitter::Base.new(oauth)
  end
end