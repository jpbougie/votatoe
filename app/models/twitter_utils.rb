class TwitterUtils
  def self.message_id(url_or_id)
    return url_or_id if /^\d+$/ =~ url_or_id
    
    return url_or_id.split("/").select {|part| !part.empty?}[-1]
  end
  
  # get the username from the url to a status update on twitter.com
  def self.username(url)
    # example url
    # http://www.twitter.com/<username>/status/<status_id>
    
    /twitter\.com\/([^\/]+)\//i.match(url)[1]
  end
  
  def self.get_user_id username
    HTTParty.get("http://api.twitter.com/1/users/show/#{username}.json")['id']
  end
end