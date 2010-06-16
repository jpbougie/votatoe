class EnqueueUpdateJobs
  @queue = :meta
  def self.perform
    # get the active users (ie. those who actually have polls)
    # and enqueue the update jobs for those
    User.active.each {|u| Resque.enqueue(FetchVotes, u.twitter_id) }
  end
end