require 'rubygems'
require 'bundler'
Bundler.setup

require 'rspec'
require 'mongoid'
require 'mongoid-rspec'
require 'database_cleaner'
require 'pry-byebug'

require 'mongoid/seo'
require 'mongoid/slug'

cwd = File.dirname(__FILE__)

Dir["#{cwd}/support/**/*.rb"].each { |f| require f }

Mongoid.load!("#{cwd}/../config/mongoid.yml", :test)

RSpec.configure do |config|
  config.include RSpec::Matchers
  config.include Mongoid::Matchers, type: :model
  config.mock_with :rspec

  config.before(:suite) { DatabaseCleaner[:mongoid].strategy = :truncation }
  config.before(:each)  { DatabaseCleaner[:mongoid].start }
  config.after(:each)   { DatabaseCleaner[:mongoid].clean }
end
