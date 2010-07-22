class HomeController < ApplicationController
  def index
    redirect_to "/dashboard" if signed_in?
  end
end
