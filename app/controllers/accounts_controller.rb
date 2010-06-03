class AccountsController < ApplicationController
  before_filter :authenticate
  def show
    @polls = cassandra.get(:UserPoll, session[:user].to_s)
  end
end
