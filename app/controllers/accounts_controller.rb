class AccountsController < ApplicationController
  before_filter :authenticate
  def show
    @polls = user.polls
  end
end
