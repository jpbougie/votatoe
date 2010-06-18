module ApplicationHelper
  def twitter_profile_image
    @profile_image ||= Rails.cache.read("twitter_profile_picture:#{session[:user]}") ||
        begin
          url = twitter.user(session[:user]).profile_image_url
          Rails.cache.write("twitter_profile_picture:#{session[:user]}", url)
          url
        end
  end
  
  def profiles(users)
    twitter.users(*users)
  end
end
