class Poll
  def self.add_vote(poll_id, user_id, status_id, choice, full_text)
    cassandra ||= Cassandra.new("Votwitter")
    cassandra.insert(:Vote, status_id.to_s, {'text' => full_text, 'user' => user_id, 'poll' => poll_id})
    cassandra.insert(:SortedVote, poll_id.to_s, {choice => { user_id => status_id}})
    
    increment_cache! poll_id, choice
  end
  
  def self.create(status_id, user_id, text)
    cassandra.insert(:Poll, status_id.to_s, {"owner" => user_id, "text" => text})
    cassandra.insert(:UserPoll, user_id.to_s, {status_id.to_i => status_id.to_s})
  end
  
  
  def self.cassandra
    @cassandra ||= Cassandra.new("Votwitter", "127.0.0.1:9160", :timeout => 10000)
  end
  
  def self.cassandra= cass
    @cassandra = cass
  end
  
  def self.choices poll_id
    cassandra.get(:SortedVote, poll_id, :count => 1).keys
  end
  
  def self.results poll_id
    results = {}
    
    choices(poll_id).each do |choice|
      unless count = get_count_from_cache(poll_id, choice)
        reset_caches! poll_id
        count = get_count_from_cache(poll_id, choice)
      end
      results[choice] = count.to_i
    end
    
    results
  end
  
  def self.votes poll_id
    Rails.cache.read(['poll', poll_id, 'votes'].join(":"), :raw => true).to_i
  end
  
  def self.reset_caches! poll_id
    poll = cassandra.get(:Poll, poll_id)
    choices = cassandra.get(:SortedVote, poll_id, :count => 1).keys
    sum = 0
    choices.each do |choice|
      count = cassandra.count_columns(:SortedVote, poll_id, choice)
      sum += count
      Rails.cache.write(['poll', poll_id, 'count', choice].join(":"), count, :raw => true)
    end
    Rails.cache.write(['poll', poll_id, 'votes'].join(":"), sum, :raw => true)
  end
  
  def self.increment_cache! poll_id, choice
    key = ['poll', poll_id, 'count', choice].join(":")
    total_key = ['poll', poll_id, 'votes'].join(":")
    Rails.cache.write(key, '0', :unless_exist => true, :raw => true)
    Rails.cache.increment(key)
    Rails.cache.write(total_key, '0', :unless_exist => true, :raw => true)
    Rails.cache.increment(total_key)
  end
  
  def self.get_count_from_cache poll_id, choice
    key = ['poll', poll_id, 'count', choice].join(":")
    Rails.cache.read(key, :raw => true)
  end
  
  
  def self.guess_poll_type(text)
    case text
      when /^who\s/i then "who"
      when /^what\s/i then "what"
      when /^do(es)?\s/i then "yesno"
      when /^how\s/i then "how"
      else "other"
    end
  end
  
  extend Twitter::Extractor
  def self.guess_choices(text)
    users = extract_mentioned_screen_names(text)
    hashtags = extract_hashtags(text)
    
    (users.blank? && hashtags) || users
  end
  
  def self.choices_described?(text)
    !guess_choices(text).blank?
  end
end