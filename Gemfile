source 'https://rubygems.org'
ruby '1.9.3'

gem 'rails', '~> 3.2.13'
gem 'pg'
gem 'yappconfig'
gem 'twitter'
gem 'nokogiri'
gem 'typhoeus'
gem 'haml-rails'
gem 'rails_admin'
gem 'gon'
gem 'simple_form'
gem 'devise'
gem 'maruku'

# Authorization/Authentication
gem 'omniauth'
gem 'omniauth-twitter'
gem 'cancan'
gem 'httparty' # Someone forgot to add this to the FastSpring dependencies...
gem 'FastSpring', '~> 1.0.0', github: 'jalada/fastspring-ruby'

group :development do
  gem 'capistrano'
  gem 'rvm-capistrano'
  gem 'foreman'
end

gem 'unicorn'

group :production do
  gem 'exception_notification'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'uglifier', '>= 1.0.3'
  gem 'bootstrap-sass'
  gem 'turbo-sprockets-rails3'
  gem 'jquery-datatables-rails'
end

gem 'jquery-rails'

gem 'rspec-rails', :group => [:test, :development]
group :test do
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'spork-rails'
  gem 'guard-spork'
  gem 'rb-fsevent', :require => false
  gem 'ruby_gntp'
end
