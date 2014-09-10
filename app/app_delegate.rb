# class AppDelegate
#   def application(_, didFinishLaunchingWithOptions:_)
#     return true if RUBYMOTION_ENV == 'test'
#   end
# end

# class Post < Courier::Base
#   property :id, Integer32, key: true
#   property :user_id, Integer32
#   property :title, String
#   property :body, String
#
#   self.individual_path = "posts/:id"
#   self.collection_path = "posts"
#   self.json_to_local = {id: :id, userId: :user_id, title: :title, body: :body}
# end

class AppDelegate
  def application(_, didFinishLaunchingWithOptions:_)
    return true if RUBYMOTION_ENV == "test"
    # Courier::nuke.everything.right.now
    #
    # @c = Courier::Courier.instance
    # @c.url = "http://jsonplaceholder.typicode.com"
    # @c.parcels = [Post]
    #
    # p = Post.create
    # p.id = 4
    # p.fetch do |fp|
    #   puts "fp is #{fp.inspect}"
    #   fp.true_class.properties.each do |pr|
    #     val = fp.send("#{pr.name}")
    #     puts "  #{pr.name} = #{val}"
    #   end
    #
    #   fp.merge_if { false }
    #   puts "p is #{p.inspect}"
    #   p.true_class.properties.each do |pr|
    #     val = p.send("#{pr.name}")
    #     puts "  #{pr.name} = #{val}"
    #   end
    # end

    # puts "fetch was #{p.fetch!}"
    # NSThread.sleepForTimeInterval(1.0)
    # puts "p is #{p.inspect}"
    # p.true_class.properties.each do |pr|
    #   val = p.send("#{pr.name}")
    #   puts "  #{pr.name} = #{val}"
    # end

    # p = Post.create
    # p.id = 4
    # p.fetch do
    #   puts "2 locked? #{@c.locked?}"
    #   puts "post title: #{p.title}"
    #   x = p.save
    #   puts "x is #{x}"
    # end
    # puts "1 locked? #{@c.locked?}"

    true
  end
end
