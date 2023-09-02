# config valid for current version and patch releases of Capistrano
lock "~> 3.14.0"

set :application, 'oscar-master-dashboard'
set :repo_url, "git@github.com:rotati/#{fetch(:application)}.git"
set :deploy_to, "/var/www/#{fetch(:application)}"
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', "public/packs", ".bundle", "node_modules")
set :linked_files, fetch(:linked_files, []).push('.env')

set :rvm_ruby_version, '2.7.0@oscar-md'
set :pty, false
set :keep_releases, 5
set :passenger_restart_with_touch, true
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
