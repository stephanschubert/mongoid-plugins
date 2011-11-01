require 'rubygems'
require 'bundler/setup'

require 'mongoid'
require 'mongoid/seo'

require 'rspec'
require 'mongoid-rspec'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include RSpec::Matchers
  config.include Mongoid::Matchers

  config.mock_with :rspec
end
