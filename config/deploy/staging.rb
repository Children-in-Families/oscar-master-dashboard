set :stage, 'staging'
server '52.220.217.164', user: 'deployer', roles: %w{app web db}
