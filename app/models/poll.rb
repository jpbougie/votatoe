class Poll
  def self.add_vote(poll_id, user_id, status_id, choice, full_text)
    cassandra ||= Cassandra.new("Votwitter")
    cassandra.insert(:Vote, poll_id.to_s, {choice => { user_id => status_id}})
    
    increment_cache! poll_id, choice
  end
  
  def self.create(status_id, user_id, text)
    cassandra.insert(:Poll, status_id.to_s, {"owner" => user_id, "text" => text})
  end
  
  
  def self.cassandra
    @cassandra ||= Cassandra.new("Votwitter")
  end
  
  def self.cassandra= cass
    @cassandra = cass
  end
  
  def self.reset_caches! poll_id
    poll = cassandra.get(:Poll, poll_id)
    choices = cassandra.get(:Vote, poll_id, :count => 1).keys    
    choices.zip(votes).each do |choice, count|
      Rails.cache.write(['poll', poll_id, 'count', choice].join(":"), cassandra.count_columns(:Vote, poll_id, choice))
    end
    
  end
  
  def self.increment_cache! poll_id, choice
    Rails.cache.inc(['poll', poll_id, 'count', choice])
  end
end