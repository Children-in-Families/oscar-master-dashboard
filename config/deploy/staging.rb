set :stage, 'staging'
set :branch, 'staging'
server '3.0.131.11', user: 'deployer', roles: %w{app web}
