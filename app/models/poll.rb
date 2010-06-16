class Poll < ActiveRecord::Base
  belongs_to :user
  has_many :votes
  
  def choices
    self.votes.select("DISTINCT choice").map(&:choice)
  end
end
