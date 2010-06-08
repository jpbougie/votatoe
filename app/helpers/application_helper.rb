module ApplicationHelper
  def twitter_profile_image
    @profile_image ||= twitter.user(session[:user]).profile_image_url
  end
  
  def profiles(users)
    twitter.users(users)
  end
end
