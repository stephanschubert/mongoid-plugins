Gem::Specification.new do |s|
  s.name        = "mongoid-plugins"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY

  s.summary     = "A collection of modules/plugins for Mongoid."
  s.description = "A collection of modules/plugins for Mongoid."
  s.files       = `git ls-files`.split("\n")

  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'mongoid'
  s.add_runtime_dependency 'bson_ext'
  s.add_runtime_dependency 'mongo_ext'
  s.add_runtime_dependency 'urlify'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'mongoid-rspec'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'pry-byebug'
end
