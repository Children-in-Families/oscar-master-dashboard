set :stage, 'production'
server '52.221.46.112', user: 'deployer', roles: %w{app web}
set :branch, 'feat/dashboard-v2'
