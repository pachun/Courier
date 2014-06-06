# class AppDelegate
#   def application(_, didFinishLaunchingWithOptions:_)
#     return true if RUBYMOTION_ENV == 'test'
#   end
# end

class Post < Courier::Base
  property :id, Integer32
  property :user_id, Integer32
  property :title, String
  property :body, String

  self.individual_path = "posts/:id"
  self.collection_path = "posts"
  self.json_to_local = {id: :id, userId: :user_id, title: :title, body: :body}
end

class AppDelegate
  def application(_, didFinishLaunchingWithOptions:_)
    return true if RUBYMOTION_ENV == "test"
    Courier::nuke.everything.right.now

    @c = Courier::Courier.instance
    @c.url = "http://jsonplaceholder.typicode.com"
    @c.parcels = [Post]

    # p = Post.create
    # p.id = 4
    # p.fetch do
    #   puts "2 locked? #{@c.locked?}"
    #   puts "post title: #{p.title}"
    #   x = p.save
    #   puts "x is #{x}"
    # end
    # puts "1 locked? #{@c.locked?}"
    # true

    Post.fetch_all do
      puts "posts: #{Post.all.map{|p|p.title}.inspect}"
    end
  end
end
