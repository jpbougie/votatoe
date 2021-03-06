class FetchVotes
  @queue = :twitter_fetch
  def self.perform(user_id)
    # fetch the user's oauth credentials
    user = User.find_by_twitter_id(user_id)
    
    youngest_id = user.polls.minimum(:last_seen_id)
    poll_ids = user.polls.map(&:status_id)
    
    #fetch all the mentions, and only keep those whose in_reply_to_status_id is equal to status_id
    # because of the 200 limit, we page the request
    
    query = {:count => 200, :include_entities => true}
    
    if youngest_id
      query[:since_id] = youngest_id
    end
    
    has_more_pages = true
    begin
      user.use_twitter do |twitter|
        begin
          # do the actual request to the API
          mentions = twitter.mentions(query)
          if mentions.length > 0
            # take the last item as the first of the new batch
            query.merge!( {:max_id => mentions[-1]['id']})
          end
      
          mentions.select {|m| rid = m.in_reply_to_status_id; poll_ids.include?(rid)}.each do |vote|
            # ignore votes that have already been registered
            poll = user.polls.find_by_status_id(vote.in_reply_to_status_id)
            unless Vote.exists?(:author => vote.user[:id], :poll_id => poll.id)
          
              # TODO make better rules to find out what is interesting in the poll
              choice = if !vote.entities.hashtags.blank?
                vote.entities.hashtags.first.text
              elsif vote.entities.user_mentions.length > 1 #the first mention will always be the user who created the poll
                vote.entities.user_mentions[1].text
              else
                "unknown"
              end
            
              # add the vote into the database
              Tweet.create(:status_id => vote[:id], :payload => ActiveSupport::JSON.encode(vote))
              poll.votes
                  .create(:status_id => vote[:id],
                          :author => vote.user[:id],
                          :username => vote.user[:screen_name],
                          :text => vote.text,
                          :agent => vote.source,
                          :choice => choice)
                        
                        
              # add the profile picture to the cache
              Rails.cache.write("twitter_profile_picture:#{vote.user[:id]}", vote.user[:profile_image_url])
            end
          end
          # continue while we're capped
          has_more_pages = (mentions.length == 200)
        end while has_more_pages
      end
      
      # set the last seen id
      if query[:max_id]
        user.polls.update_all(:last_seen_id => query[:max_id])
      end
    rescue TwitterError
      # the job will be re-run in 5 minutes, so just ignore the error
    end
  end
end