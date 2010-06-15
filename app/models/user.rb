require 'twitter_ext'

class User < ActiveRecord::Base
  has_many :polls
  
  def use_twitter(&block)
    account = Account.find(self.id)
    
    Twitter.with_access(account.token, account.secret, &block)
  end
end
