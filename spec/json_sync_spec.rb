describe "The Courier Base Class' JSON resource syncing functionality" do
  behaves_like "A Core Data Spec"

  before do
    if Object.constants.include?(:Post)
      Object.send(:remove_const, :Post)
    end

    @post_json = {"title"=>"eum et est occaecati", "id"=>4, "userId"=>1, "body"=>"ullam et saepe reiciendis voluptatem adipiscisit amet autem assumenda provident rerum culpaquis hic commodi nesciunt rem tenetur doloremque ipsam iurequis sunt voluptatem rerum illo velit"}

    class Post < Courier::Base
      property :id, Integer32, key: true
      property :user_id, Integer32, key: true
      property :title, String
      property :body, String

      self.individual_path = "posts/:id"
      self.collection_path = "posts"
      self.json_to_local = {id: :id, userId: :user_id, title: :title, body: :body}
    end

    @c = Courier::Courier.instance
    @c.url = "http://jsonplaceholder.typicode.com"
    @c.parcels = [Post]

    @post = Post.create
    @post.id = 4
  end

  it "saves the individual resource path, collection resource path, and json key mapping to the base object's class" do
    Post.individual_path.should == "posts/:id"
    Post.collection_path.should == "posts"
    Post.json_to_local.should == {id: :id, userId: :user_id, title: :title, body: :body}
  end

  it "soft .fetch's individual resources in a different context" do
    prior_num_contexts = @c.contexts.count
    @post._save_single_resource_in_new_context(@post_json) do |fetched_resource|
      fetched_resource.true_class.should == @post.true_class
      @c.contexts.count.should == prior_num_contexts + 1
      fetched_resource.context.should != @post.context
      fetched_resource.title.should == @post_json["title"]
      fetched_resource.id.should == @post_json["id"]
      fetched_resource.user_id.should == @post_json["userId"]
      fetched_resource.body.should == @post_json["body"]
    end
  end

  it "hard .fetch!'s individual resource in the same context" do
    prior_num_contexts = @c.contexts.count
    old_post_context = @post.context
    @post._save_single_resource_in_same_context(@post_json) do
      @post.title.should == @post_json["title"]
      @post.id.should == @post_json["id"]
      @post.user_id.should == @post_json["userId"]
      @post.body.should == @post_json["body"]
      @post.context.should == old_post_context
      @c.contexts.count.should == prior_num_contexts
    end
  end

  it "generates its post parameters correctly" do
    @post.user_id = 10
    @post.post_parameters.should == {id: 4, userId: 10}
    @post.title = "Hello World"
    @post.post_parameters.should == {id: 4, userId: 10, title: "Hello World"}
  end

  it "knows which properties are keys" do
    Post.keys.should == [:id, :user_id]
  end

  # it translates key: :default to an integer increment that auto assigns 0,1,2,3,4
  #   also checks db for highest existing id and assigns next one (if 11 is in db, assigns 12)
end
