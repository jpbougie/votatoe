require 'pp'

class PollController < ApplicationController
  def create
    if request.get?
      render
    elsif request.post?
      twitter_status_url = params[:tweet][:status_url]
      
      username = TwitterUtils.username(twitter_status_url)
      
      user_id = TwitterUtils.get_user_id(username)
      
      user = cassandra.get(:User, user_id.to_s)

      logger.debug(user)
      
      if user && authenticated?(user)
        status_id = TwitterUtils.message_id(twitter_status_url)
        twitter = Twitter::Base.new(oauth)
        Poll.create(status_id.to_s, user_id.to_s, twitter.status(status_id)['text'])
        Resque.enqueue(FetchOldVotes, status_id, user_id)
        
        redirect_to show_url(status_id)
      else
        oauth.set_callback_url("http://augur.local:3000/authorized")
        session['status_url'] = twitter_status_url
        session['rtoken']  = oauth.request_token.token
        session['rsecret'] = oauth.request_token.secret

        logger.debug(session['rtoken'])
        logger.debug(session['rsecret'])

        redirect_to oauth.request_token.authorize_url
        
        
      end
    end
  end
  
  def authorized

    oauth.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])

    twitter = Twitter::Base.new(oauth).verify_credentials
    session['rtoken'] = session['rsecret'] = nil
    session[:atoken] = oauth.access_token.token
    session[:asecret] = oauth.access_token.secret
    
    user_id = TwitterUtils.get_user_id(session[:status_url])
    status_id = TwitterUtils.message_id(session[:status_url])
    cassandra.insert(:User, user_id, {"token" => session[:atoken], "secret" => session[:asecret]})
    
    tweet = twitter.show(status_id)
    
    Poll.cassandra = cassandra
    Poll.create(status_id, tweet['user']['id'], tweet['status'])
    Resque.enqueue(FetchOldVotes, status_id, tweet['user']['id'])
    
    redirect_to poll_url(status_id)
  end

  def show
    @poll = cassandra.get(:Poll, params[:id])
  end

end
