# class Fixnum
#   def seconds
#     self
#   end
#
#   def minutes
#     seconds * 60
#   end
#
#   def hours
#     minutes * 60
#   end
#
#   def days
#     hours * 24
#   end
#
#   def weeks
#     days * 7
#   end
# end
#
# class Post < Courier::Base
#   conflict_policy :overwrite_local
#   cache_policy 20.seconds
#
#   property :id, Integer32, required: true, key: true
#   property :title, String
#   property :body, String
#
#   self.collection_path = "posts"
#   self.individual_path = "posts/:id"
# end
#
# class AppDelegate
#   def application(_, didFinishLaunchingWithOptions:_)
#     Courier::nuke.everything.right.now
#     return true if RUBYMOTION_ENV == "testing"
#     Courier::Courier.instance.tap do |c|
#       c.parcels = [Post]
#       c.url = "http://jsonplaceholder.typicode.com"
#     end
#     # Post.find_all do |posts|
#     #   puts "posts: #{posts}"
#     # end
#     # Post.find_all do |conflicts|
#     #   puts "\nconflicts: #{conflicts.inspect}"
#     # end
#     Post.find(id: 4) do |post|
#       puts "post: #{post.inspect}"
#     end
#     true
#   end
# end
