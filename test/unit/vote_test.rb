require 'test_helper'

class VoteTest < ActiveSupport::TestCase
  should "be valid" do
    assert Vote.new.valid?
  end
end
