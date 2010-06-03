class FetchVotes
  @queue = :twitter_fetch
  
  def self.oauth
    @oauth ||= begin
      conf = File.open(File.join(File.dirname(__FILE__), '..', '..', 'config', 'twitter.yml') ) { |yf| YAML::load( yf ) }
      Twitter::OAuth.new(conf['development']['token'], conf['development']['secret'])
    end
  end
  
  def self.perform(user_id)
    # fetch the user's oauth credentials
    cassandra = Cassandra.new("Votwitter")
    Poll.cassandra = cassandra
    user = cassandra.get(:User, user_id.to_s)
    
    token, secret = user['token'], user['secret']
    # using those credentials, start the client
    oauth.authorize_from_access(token, secret)
    twitter = Twitter::Base.new(oauth)
    
    # fetch the user's polls
    # the columns are poll_id => last_seen_id
    # at first, the last_seen_id is set to the poll itself
    polls = cassandra.get(:UserPoll, user_id.to_s)
    poll_ids = polls.keys.collect {|k| k.to_i }
    
    youngest_id = polls.values.min
    
    #fetch all the mentions, and only keep those whose in_reply_to_status_id is equal to status_id
    # because of the 200 limit, we page the request
    
    query = {:since_id => youngest_id, :count => 200, :include_entities => true}
    continue = true
    
    begin
      # do the actual request to the API
      mentions = twitter.mentions(query)
      if mentions.length > 0
        # take the last item as the first of the new batch
        query.merge!( {:max_id => mentions[-1]['id']})
      end
      
      mentions.select {|m| rid = m.in_reply_to_status_id; poll_ids.include?(rid) && m.id > polls[Cassandra::Long.new(rid)].to_i  }.each do |vote|
        # TODO make better rules to find out what is interesting in the poll
        choice = if !vote.entities.hashtags.empty?
          vote.entities.hashtags.first.text
        elsif vote.entities.user_mentions.length > 1 #the first mention will always be the user who created the poll
          vote.entities.user_mentions[1].text
        end
        # add the vote into the database
        Poll.add_vote(vote.in_reply_to_status_id.to_s, vote.user[:id].to_s, vote[:id].to_s, choice, vote.text)
      end
      # continue while we're capped
      continue = (mentions.length == 200)
    end while continue
    
    # set the last seen id
    if query[:max_id]
      cassandra.insert(:UserPoll, user_id.to_s, polls.merge(polls) {|p, v| query[:max_id].to_s})
    end
  end
  
end