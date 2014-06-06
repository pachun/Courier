#
# old, deprecated when bubble-wrap dropped support for it's http module
#

# describe "The Courier Base Class With Regard to Fetching" do
#   behaves_like "A Core Data Spec"
#
#   before do
#     if Object.constants.include?(:Post)
#       Object.send(:remove_const, :Post)
#     end
#
#     class Post < Courier::Base
#       property :id, Integer32
#       property :user_id, Integer32
#       property :title, String
#       property :body, String
#
#       self.individual_url = "posts/:id"
#       self.collection_url = "posts"
#       self.json_to_local = {id: :id, userId: :user_id, title: :title, body: :body}
#     end
#
#     @c = Courier::Courier.instance
#     # puts "locks1: #{@c.locks.inspect}"
#     @c.url = "http://jsonplaceholder.typicode.com"
#     @c.parcels = [Post]
#
#     @post = Post.create
#     @post.id = 4
#   end
#
#   it "saves individual and collection urls as well as a json to local mapping" do
#     Post.individual_url.should == "posts/:id"
#     Post.collection_url.should == "posts"
#     Post.json_to_local.should == {id: :id, userId: :user_id, title: :title, body: :body}
#   end
#
#   # it "provides an instance fetch method for reaching out to an individual resource at the json api" do
#   #   lambda{ @post.fetch }.should.not.raise(StandardError)
#   # end
#
#   it "locks the context properly when fetch threads are active" do
#     @post.fetch
#     @c.locked?.should == true
#     @c.save.should == false
#   end
# end
