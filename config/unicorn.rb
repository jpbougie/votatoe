# unicorn -c /data/votatoe/current/config/unicorn.rb -E production -D

rails_env = ENV['RAILS_ENV'] || 'production'

# 16 workers and 1 master
worker_processes (rails_env == 'production' ? 16 : 4)

# Load rails+votatoe.git into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30

# Listen on a Unix data socket
listen '/data/votatoe/current/tmp/sockets/unicorn.sock', :backlog => 2048

pid '/data/votatoe/shared/pids/unicorn.pid'

after_fork do |server, worker|
  worker.user('git', 'git') if Process.euid == 0
end