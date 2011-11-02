Gem::Specification.new do |s|
  s.name        = "mongoid-plugins"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY

  s.summary     = "A collection of modules/plugins for Mongoid."
  s.description = "A collection of modules/plugins for Mongoid."
  s.files       = `git ls-files`.split("\n")

  s.add_runtime_dependency 'mongoid', ['~> 2.0']
  s.add_runtime_dependency 'bson_ext', ['~> 1.3']

  # TODO We need 'jazen/santas-little-helpers' as it provides the
  #      String#to_url method.

  s.add_development_dependency 'rspec', ['~> 2.0']
  s.add_development_dependency 'mongoid-rspec', ['~> 1.4']
end
