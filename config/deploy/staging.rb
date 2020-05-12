set :stage, 'staging'
server '52.77.154.180', user: 'deployer', roles: %w{app web db}
