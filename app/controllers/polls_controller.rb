require 'pp'

class PollsController < ApplicationController
  before_filter :authenticate
  def create
    user_id = session[:user]
    
    if params[:tweet].has_key? :status_url
      twitter_status_url = params[:tweet][:status_url]
      username = TwitterUtils.username(twitter_status_url)
    
      status_id = TwitterUtils.message_id(twitter_status_url)
      Poll.create(status_id.to_s, user_id.to_s, twitter.status(status_id)['text'])
      Resque.enqueue(FetchVotes, user_id)
    
    elsif params[:tweet].has_key? :status
      status_id = twitter.update(params[:tweet][:status])
    end
    
    
    redirect_to poll_path(status_id)
  end
  
  def new
    @recent_tweets = twitter.user_timeline
  end

  def show
    @poll = cassandra.get(:Poll, params[:id])
    
    if @poll == {}
      tweet = twitter.status(params[:id])
      if tweet.user.id == session[:user]
        Poll.create(params[:id].to_s, session[:user].to_s, tweet.text)
        Resque.enqueue(FetchVotes, session[:user])
      end
    end
    
    @results = Poll.results(params[:id])
    @choices = Poll.choices(params[:id]).sort_by {|ch| @results[ch]}
    @total = Poll.votes(params[:id])
    @type = Poll.guess_poll_type(@poll['text'])
    @possible_choices = Poll.guess_choices(@poll['text'])
    
    @votes = {}
    @choices.each do |choice|
        votes = cassandra.get(:SortedVote, params[:id].to_s, choice)
        @votes[choice] = cassandra.multi_get(:Vote, votes.values)
    end
  end

end
