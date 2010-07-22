require 'pp'

class PollsController < ApplicationController
  before_filter :authenticate
  respond_to :html, :xml, :json
  def create
    user_id = session[:user]
    
    if params[:tweet].has_key? :status_url
      twitter_status_url = params[:tweet][:status_url]
    
      status_id = twitter_status_url.split("/")[-1].to_i
      
      begin
        tweet = twitter.status(status_id)
        Tweet.create(:status_id => status_id, :payload => ActiveSupport::JSON.encode(tweet))
        Poll.create(:status_id => status_id, :user => user_id, :text => tweet.text, :last_seen_id => status_id)
        Resque.enqueue(FetchVotes, user_id)
      rescue Twitter::TwitterError
        render 'application/twitter_unavailable'
      end
    
    elsif params[:tweet].has_key? :status
      status_id = twitter.update(params[:tweet][:status]).id
    end
    
    
    redirect_to poll_path(status_id)
  end
  
  def new
  end
  
  def from_existing
    begin
      @recent_tweets = twitter.user_timeline.select {|tweet| !Poll.exists?(:status_id => tweet.id)}
    rescue Twitter::TwitterError
      render 'application/twitter_unavailable'
    end
  end

  def show
    @poll = Poll.find_or_initialize_by_status_id(params[:id])
    
    if @poll.new_record?
      begin
        tweet = twitter.status(params[:id])
        Tweet.create(:status_id => params[:id], :payload => ActiveSupport::JSON.encode(tweet))
        if tweet.user.id == session[:user]
          @poll.user = user
          @poll.text = tweet.text
          @poll.last_seen_id = params[:id]
          @poll.save
          Resque.enqueue(FetchVotes, session[:user])
        end
      rescue Twitter::TwitterError
        render 'application/twitter_unavailable'
      end
    end
    
  end
  
  def lists
    @poll = Poll.find_by_status_id(params[:id])

    @lists = twitter.lists(user.username)
    logger.debug @lists
    @members = @lists.lists.inject({}) {|hash, list| hash[list.name] = twitter.list_members(user.username, list.slug).users.collect(&:id); hash}
    
    @counts = {}
    @members.each {|name, users| @counts[name] = @poll.votes.where(:author => users).count}
    
    respond_with(@counts, :to => [:json])
    
  end
  
  def filter
    @poll = Poll.find_by_status_id(params[:id])
    
    
  end
end
