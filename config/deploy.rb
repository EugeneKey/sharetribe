# config valid only for current version of Capistrano
lock "3.9.1"

set :rvm_ruby_version, '2.3.4@share-r5.1.1'
set :nvm_type, :user # or :system, depends on your nvm setup
set :nvm_node, 'v7.8.0'
set :nvm_map_bins, %w{node npm yarn}

set :repo_url,        'git@github.com:EugeneKey/sharetribe-with-sidekiq.git'
set :application,     'sharetribe'
set :user,            'ubuntu'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, ENV['BRANCH'] || 'master'

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, [])
        .push('config/database.yml', 'config/config.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, [])
        .push('bin', 'log', 'tmp/pids', 'tmp/cache', 'db/sphinx',
              'tmp/sockets', 'vendor/bundle', 'public/system',
              'public/uploads', 'client/node_modules', 'public/assets')

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/#{fetch(:branch)}"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup

  before :updating, 'thinking_sphinx:stop'
  after  :published, 'thinking_sphinx:start'

  before 'thinking_sphinx:start', 'thinking_sphinx:index'
  before 'thinking_sphinx:stop', 'thinking_sphinx_monit:unmonitor'
  after  'thinking_sphinx:start', 'thinking_sphinx_monit:monitor'

end

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5
