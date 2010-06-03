require 'pp'

class PollsController < ApplicationController
  before_filter :authenticate
  def create
    twitter_status_url = params[:tweet][:status_url]
    
    username = TwitterUtils.username(twitter_status_url)
    
    user_id = session[:user]
    
    status_id = TwitterUtils.message_id(twitter_status_url)
    oauth.authorize_from_access(user['token'], user['secret'])
    twitter = Twitter::Base.new(oauth)
    Poll.create(status_id.to_s, user_id.to_s, twitter.status(status_id)['text'])
    Resque.enqueue(FetchVotes, user_id)
      
    redirect_to poll_path(status_id)
  end
  
  def new
  end

  def show
    @poll = cassandra.get(:Poll, params[:id])
    @choices = Poll.choices(params[:id])
    @results = Poll.results(params[:id])
  end

end
