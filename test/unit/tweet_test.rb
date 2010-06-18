require 'test_helper'

class TweetTest < ActiveSupport::TestCase
  should "be valid" do
    assert Tweet.new.valid?
  end
end
