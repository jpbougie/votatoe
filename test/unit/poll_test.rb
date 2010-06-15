require 'test_helper'

class PollTest < ActiveSupport::TestCase
  should "be valid" do
    assert Poll.new.valid?
  end
end
