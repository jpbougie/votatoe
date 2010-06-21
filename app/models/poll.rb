class Poll < ActiveRecord::Base
  belongs_to :user
  has_many :votes
  
  def choices
    votes.group(:choice).order("count(votes.choice) DESC").select("votes.choice").map(&:choice)
  end
end
