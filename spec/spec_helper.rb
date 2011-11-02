require 'rubygems'
require 'bundler'
Bundler.setup

require 'rspec'
require 'mongoid'
require 'mongoid-rspec'

require 'mongoid/seo'
require 'mongoid/slug'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

Mongoid.configure do |config|
  name = "rspec-mongoid-plugins"
  host = "localhost"
  config.master = Mongo::Connection.new.db(name)
end

RSpec.configure do |config|
  config.include RSpec::Matchers
  config.include Mongoid::Matchers
  config.mock_with :rspec

  config.after :all do
    Mongoid.master.collections.select{ |c| c.name !~ /system/ }.each(&:drop)
  end
end
