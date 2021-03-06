server '127.0.0.0', port: 22, roles: [:web, :app, :db], primary: true
set :ssh_options,     { forward_agent: true, user: fetch(:user),
                        keys: %w(~/.ssh/key.pem),
                        auth_methods: %w(publickey password) }

set :rails_env, :production

set :pty,             false
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/app/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
set :puma_threads,    [0, 16]
set :puma_workers,    0

set :nginx_server_name, 'name.com'

# set :sidekiq_processes, 2
set :sidekiq_user, fetch(:user)
set :sidekiq_options_per_process, ["--queue paperclip --queue default --queue payments --queue mailers --queue ts_delta --queue low"]