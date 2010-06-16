class FetchVotes
  @queue = :twitter_fetch
  def self.perform(user_id)
    # fetch the user's oauth credentials
    user = User.find_by_twitter_id(user_id)

    
    youngest_id = user.polls.minimum(:last_seen_id)
    
    #fetch all the mentions, and only keep those whose in_reply_to_status_id is equal to status_id
    # because of the 200 limit, we page the request
    
    query = {:count => 200, :include_entities => true}
    
    if youngest_id
      query[:since_id] = youngest_id
    end
    
    continue = true
    
    user.use_twitter do |twitter|
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
          user.polls.find_by_status_id(vote.in_reply_to_status_id)
              .votes
              .create(:status_id => vote[:id], :author => vote.user[:id], :text => vote.text, :agent => vote.source)
        end
        # continue while we're capped
        continue = (mentions.length == 200)
      end while continue
    end
    
    # set the last seen id
    if query[:max_id]
      user.polls.update_all(:last_seen_id => query[:max_id])
    end
  end
  
end