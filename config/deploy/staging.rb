set :stage, 'staging'
set :branch, 'staging'
set :rvm_type, :user   # Defaults to: :auto
set :rvm_ruby_version, '2.7.0'
server '193.203.160.204', user: 'deployer', roles: %w{app web}
