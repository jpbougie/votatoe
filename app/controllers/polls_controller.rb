require 'pp'

class PollsController < ApplicationController
  before_filter :authenticate
  def create
    user_id = session[:user]
    
    if params[:tweet].has_key? :status_url
      twitter_status_url = params[:tweet][:status_url]
    
      status_id = twitter_status_url.split("/")[-1]
      tweet = twitter.status(status_id)
      Tweet.create(:status_id => status_id, :payload => ActiveSupport::JSON.encode(tweet))
      Poll.create(:status_id => status_id, :user => user_id, :text => tweet.text, :last_seen_id => status_id)
      Resque.enqueue(FetchVotes, user_id)
    
    elsif params[:tweet].has_key? :status
      status_id = twitter.update(params[:tweet][:status]).id
    end
    
    
    redirect_to poll_path(status_id)
  end
  
  def new
    #@recent_tweets = twitter.user_timeline
  end

  def show
    @poll = Poll.find_or_initialize_by_status_id(params[:id])
    
    if @poll.new_record?
      tweet = twitter.status(params[:id])
      Tweet.create(:status_id => params[:id], :payload => ActiveSupport::JSON.encode(tweet))
      if tweet.user.id == session[:user]
        @poll.user = user
        @poll.text = tweet.text
        @poll.last_seen_id = params[:id]
        @poll.save
        Resque.enqueue(FetchVotes, session[:user])
      end
    end
    
    
  end

end
