# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

require 'motion-support/inflector'
require 'webstub'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'courier'
  app.frameworks += ['CoreData']
end
