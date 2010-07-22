module PollHelper
  include Twitter::Autolink
  
  def profile_picture(user)
    
    Rails.cache.read("twitter_profile_picture:#{user}") ||
      begin
        url = twitter.user(user).profile_image_url
        Rails.cache.write("twitter_profile_picture:#{user}", url)
        url
      rescue Twitter::TwitterError
        nil
      end
  end
end
