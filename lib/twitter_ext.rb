module Twitter
  def self.with_access(token, secret)
    
    oa = oauth(true)
    oa.authorize_from_access(token, secret)
    
    yield Twitter::Base.new(oa)
  end
  
  def self.oauth(sign_in = true)
    conf = File.open(File.join(File.dirname(__FILE__), '..', 'config', 'twitter.yml') ) { |yf| YAML::load( yf ) }
    
    Twitter::OAuth.new(conf[Rails.env]['token'], conf[Rails.env]['secret'], :sign_in => sign_in)
  end
end