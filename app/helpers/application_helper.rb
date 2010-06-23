module ApplicationHelper
  def twitter_profile_image
    @profile_image ||= Rails.cache.read("twitter_profile_picture:#{session[:user]}") ||
        begin
          url = twitter.user(session[:user]).profile_image_url
          Rails.cache.write("twitter_profile_picture:#{session[:user]}", url)
          url
        rescue TwitterError
          nil
        end
  end
  
  def profiles(users)
    begin
      twitter.users(*users)
    rescue TwitterError
      nil
    end
  end
end
