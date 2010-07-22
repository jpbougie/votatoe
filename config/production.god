God.pid_file_directory = '/data/votatoe/shared/pids'
rails_env = ENV['RAILS_ENV'] || 'production'
rails_root = ENV['RAILS_ROOT'] || "/data/votatoe/current"

God.watch do |w|
  w.name = "unicorn"
  w.interval = 30.seconds # default

  w.env = {"RAILS_ENV"=>rails_env}

  w.dir = rails_root
  
  # unicorn needs to be run from the rails root
  w.start = "unicorn -E production -c #{rails_root}/config/unicorn.rb #{rails_root}/config.ru"

  # QUIT gracefully shuts down workers
  w.stop = "kill -QUIT `cat /data/votatoe/shared/pids/unicorn.pid`"

  # USR2 causes the master to re-create itself and spawn a new worker pool
  w.restart = "kill -USR2 `cat /data/votatoe/shared/pids/unicorn.pid`"

  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "/data/votatoe/shared/pids/unicorn.pid"

  w.uid = 'votatoe'
  w.gid = 'votatoe'

  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 300.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end

  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

num_workers = rails_env == 'production' ? 2 : 1

num_workers.times do |num|
  God.watch do |w|
    w.name     = "resque-#{num}"
    w.group    = 'resque'
    w.interval = 30.seconds
    w.env      = {"QUEUE"=>"*", "RAILS_ENV"=>rails_env}
    w.start    = "/usr/local/bin/rake -f #{rails_root}/Rakefile environment resque:work"

    w.dir = rails_root
    w.log = "#{rails_root}/log/resque-#{num}.log"
    
    w.uid = 'votatoe'
    w.gid = 'votatoe'

    # retart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end


God.watch do |w|
  w.name     = "resque-scheduler"
  w.interval = 30.seconds
  w.env      = {"QUEUE"=>"*", "RAILS_ENV"=>rails_env}
  w.start    = "/usr/local/bin/rake -f #{rails_root}/Rakefile environment resque:scheduler"

  w.uid = 'votatoe'
  w.gid = 'votatoe'

  # retart if memory gets too high
  w.transition(:up, :restart) do |on|
    on.condition(:memory_usage) do |c|
      c.above = 350.megabytes
      c.times = 2
    end
  end

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end
