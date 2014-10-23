# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'courier'
  app.frameworks += ['CoreData']

  app.files_dependencies "app/app_delegate.rb" => "app/courier/base/courier_base_relationships.rb"
  app.files_dependencies "app/courier/base/courier_base_relationships.rb" => "app/courier/base/courier_base_barebones.rb"
  app.files_dependencies "app/courier/base/courier_base_barebones.rb" => "app/courier/base/courier_base_default_properties.rb"
end
