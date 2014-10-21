Gem::Specification.new do |s|
  s.name        = 'motion-courier'
  s.version     = '0.3.7'
  s.date        = '2014-02-19'
  s.summary     = "A Core Data abstraction for rubymotion."
  s.description = "A RubyMotion abstraction of Core Data that also provides shortcuts for fetching json resources."
  s.authors     = ["Nick Pachulski"]
  s.email       = 'hello@nickpachulski.com'
  s.files       = ["lib/motion-courier.rb"]
  s.homepage    = 'http://pachulski.me'
  s.license     = 'MIT'

  s.add_dependency 'afmotion', '>= 2.1.4'
end
