 Resque.schedule = { :queue_updates => {
    "class" => EnqueueUpdateJobs,
    "queue" => "meta",
    "cron" => "*/5 * * * *", # every 5 minutes
    "description" => "Enqueues the update job for each active user"
  }}