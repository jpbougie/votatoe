class EnqueueUpdateJobs
  @queue = :meta
  def self.perform
    cassandra = Cassandra.new("Votwitter")
    
    users = cassandra.get_range(:User).collect {|r| r.key}
    
    # enqueues those who actually have polls
    users.select {|u| cassandra.get(:UserPoll, u, :count => 1) != {} }.each {|u| Resque.enqueue(FetchVotes, u)}
  end
end