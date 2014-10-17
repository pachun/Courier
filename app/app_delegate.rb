class Post < Courier::Base
  property :id, Integer32, key: true
  property :user_id, Integer32
  property :title, String
  property :body, String

  def self.headers
    {
      "Accept" => "application/json"
    }
  end

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

    Post.find(id: 4) do |result|
      if result[:response].success?
        puts "got: #{result[:resource]}"
      else
        puts "bad: #{result[:response].error.localizedDescription}"
      end
    end

    Post.find_all do |result|
      if result[:response].success?
        puts "got: #{result[:conflicts].inspect}"
      else
        puts "bad: #{result[:response].error.localizedDescription}"
      end
    end

    # p = Post.create
    # p.id = 4
    # p.fetch do |fp|
    #   fp.true_class.properties.each do |pr|
    #     val = fp.send("#{pr.name}")
    #     puts "  #{pr.name} = #{val}"
    #   end
    # end

    true
  end
end
