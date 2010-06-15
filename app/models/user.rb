class User < ActiveRecord::Base
  has_many :polls
end
