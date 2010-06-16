module PollHelper
  include Twitter::Autolink
  
  def profile_picture(user)
    twitter.user(user).profile_image_url
  end
end
