source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.0'
gem 'rails', '~> 6.0.2', '>= 6.0.2.2'
gem 'puma', '~> 4.1'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 4.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'pg'
gem 'dotenv-rails'
gem 'devise'
# gem 'bootstrap-sass'
gem 'bootstrap', '~> 4.5.3'
# gem 'active_bootstrap_skin'
gem 'country_select'
gem 'apartment', :github => 'influitive/apartment', :ref => 'f266f73e58835f94e4ec7c16f28443fe5eada1ac'
gem 'carrierwave'
gem 'mini_magick'
gem 'fog-aws'

gem 'sidekiq', '~> 4.1.0'
gem 'httparty'
gem 'paper_trail'

group :production, :staging do
  gem 'asset_sync'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem "capistrano", "~> 3.14", require: false
  gem "capistrano-rails", "~> 1.4", require: false
  gem 'capistrano-rvm'
  gem 'capistrano-passenger'
  gem 'ed25519'
  gem 'bcrypt_pbkdf'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "ransack", "~> 2.3"

gem "responders", "~> 3.0"

gem "simple_form", "~> 5.2"

gem "kaminari", "~> 1.2"

gem "acts_as_paranoid", "~> 0.8.1"

gem "inherited_resources", "~> 1.13"

gem "pundit", "~> 2.3"

gem "enumerize", "~> 2.7"

gem "caxlsx", "~> 3.0"
gem "ahoy_email", "1.0.3"
