class User < Courier::Base
  has_many :posts, as: :posts, on_delete: :cascade, inverse_name: :owner
end

class Post < Courier::Base
  conflict_policy :overwrite_local

  belongs_to(:user, as: :owner, on_delete: :nullify, inverse_name: :posts)

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
  # self.json_to_local = {id: :id, userId: :user_id, title: :title, body: :body}
end

class IOSLocation < Courier::Base
  has_many :IOSTickets, as: :tickets, on_delete: :nullify, inverse_name: :location
end
class IOSTicket < Courier::Base
  belongs_to :IOSLocation, as: :location, on_delete: :nullify, inverse_name: :tickets
end

class AppDelegate
  def application(_, didFinishLaunchingWithOptions:_)
    return true if RUBYMOTION_ENV == "test"
    Courier::nuke.everything.right.now

    @c = Courier::Courier.instance
    @c.url = "http://jsonplaceholder.typicode.com"
    @c.parcels = [IOSLocation, IOSTicket]

    # puts "Post.all: #{Post.all}"

    # Post.find_all do |result|
    #   if result[:response].success?
    #     puts "got: #{result[:conflicts].inspect}"
    #     Courier.save
    #   else
    #     puts "bad: #{result[:response].error.localizedDescription}"
    #   end
    # end

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
