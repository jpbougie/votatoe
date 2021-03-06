set :application, "votatoe"
set :repository,  "git://github.com/jpbougie/votatoe.git"

set :rails_env, "production"

set :use_sudo, false


set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "linode"                          # Your HTTP server, Apache/etc
role :app, "linode"                          # This may be the same as your `Web` server
role :db,  "linode", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

set :deploy_to, "/data/#{application}"

after "deploy:update", "twitter:move_config"

namespace :twitter do
  task :move_config do
    run " cp #{shared_path}/twitter.yml #{current_path}/config/twitter.yml"
  end
end

after "deploy:update", "compass:allow_compiled_dir"
namespace :compass do
  task :allow_compiled_dir do
    run "chmod a+r #{current_path}/public/stylesheets"
  end
end

after "deploy:update", "compass:compile"
namespace :compass do
  task :compile do
    run "compass compile #{current_path}"
  end
end

after "deploy:update_code" do
  deploy.bundle
end

namespace :deploy do
  task :bundle do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle install #{shared_path}/bundle"
  end
  
  task :start do
    sudo 'god start unicorn resque-work resque-scheduler'
  end
  
  task :stop do
    sudo 'god stop unicorn resque-work resque-scheduler'
  end
  
  task :restart do
    sudo 'god restart unicorn resque-work resque-scheduler'
  end
  
  task :status do
    sudo 'god status'
  end
end