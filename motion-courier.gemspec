Gem::Specification.new do |s|
  s.name        = 'motion-courier'
  s.version     = '0.1.1'
  s.date        = '2014-02-19'
  s.summary     = "A Core Data abstraction for rubymotion."
  s.description = "A RubyMotion abstraction of Core Data that also provides shortcuts for fetching json resources."
  s.authors     = ["Nick Pachulski"]
  s.email       = 'hello@nickpachulski.com'
  s.files       = ["lib/motion-courier.rb"]
  s.homepage    = 'http://pachulski.me'
  s.license     = 'MIT'

  # s.add_dependency "motion-support", ">=0.2.6"
  s.add_runtime_dependency 'motion-support', '~> 0.2', '>= 0.2.6'
end
