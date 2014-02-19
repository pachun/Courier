unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

Motion::Project::App.setup do |app|
  puts "here1"
  Dir.glob(File.join(File.dirname(__FILE__), 'motion-courier/**/*.rb')).each do |file|
    puts "unshifting #{file}"
    app.files.unshift(file)
  end
  puts "here2"
  app.frameworks += ["CoreData"]
end
