describe "The Courier Base Class' JSON resource syncing functionality" do

  before do
    Courier::nuke.everything.right.now

    if Object.constants.include?(:User)
      Object.send(:remove_const, :User)
    end
    if Object.constants.include?(:Post)
      Object.send(:remove_const, :Post)
    end

    @post_json = {
      "title" => "eum et est occaecati",
      "id" => 4,
      "userId" => 1,
      "body" => "ullam et saepe reiciendis voluptatem adipiscisit amet autem assumenda provident rerum culpaquis hic commodi nesciunt rem tenetur doloremque ipsam iurequis sunt voluptatem rerum illo velit",
    }

    class Post < Courier::Base
      belongs_to :user, as: :user, on_delete: :nullify, inverse_name: :posts

      property :id, Integer32, key: true
      property :user_id, Integer32
      property :title, String
      property :body, String

      self.individual_path = "posts/:id"
      self.collection_path = "posts"
      self.json_to_local = {id: :id, userId: :user_id, title: :title, body: :body}
    end

    class User < Courier::Base
      has_many :posts, as: :posts, on_delete: :cascade, inverse_name: :user

      property :id, Integer32, key: true
      self.collection_path = "users"
      self.individual_path = "users/:id"
      self.json_to_local = {id: :id}
    end

    @c = Courier::Courier.instance
    @c.url = "http://jsonplaceholder.typicode.com"
    @c.parcels = [User, Post]

    @post = Post.create
    @post.id = 4
  end

  it "Doesn't overwrite the path/to_json class vars when a second Courier::Base subclass is defined" do
    Post.collection_path.should == "posts"
    User.collection_path.should == "users"
  end

  it "saves the individual resource path, collection resource path, and json key mapping to the base object's class" do
    Post.individual_path.should == "posts/:id"
    Post.collection_path.should == "posts"
    Post.json_to_local.should == {id: :id, userId: :user_id, title: :title, body: :body}
  end

  it "resolves the individual url of a resource correctly" do
    @post.individual_url.should == "http://jsonplaceholder.typicode.com/posts/4"
  end

  it "resolves the collection url of a resource correctly" do
    Post.collection_url.should == "http://jsonplaceholder.typicode.com/posts"
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

  it "allows a soft-fetched individual resource to be .delete'd from its context" do
    prior_num_contexts = @c.contexts.count
    @post._save_single_resource_in_new_context(@post_json) do |fetched_resource|
      fetched_resource.delete!
      @c.contexts.count.should == prior_num_contexts
    end
  end

  it "allows a soft-fetched individual resource to be .delete!'d along with its new context" do
    prior_num_contexts = @c.contexts.count
    @post._save_single_resource_in_new_context(@post_json) do |fetched_resource|
      new_context = fetched_resource.context
      num_posts_before_delete = Post.all_in_context(new_context).count
      fetched_resource.delete!
      @c.contexts.count.should == prior_num_contexts
    end
  end

  it "knows which properties are primary keys" do
    Post.keys.should == [:id]
  end

  it "can identify (find) a main context match to a fetched resource (by comparing primary keys)" do
    other_post_json = {id: 2}
    @post._save_single_resource_in_new_context(@post_json) do |fetched_resource|
      fetched_resource.main_context_match.should == @post
    end
    @post._save_single_resource_in_new_context(other_post_json) do |fetched_resource|
      fetched_resource.main_context_match.should == nil
    end
  end

  it "provides .merge! which will overwrite the corresponding resource if it exists" do
    prior_num_contexts = @c.contexts.count
    @post._save_single_resource_in_new_context(@post_json) do |fetched_resource|
      fetched_resource.merge!.should == true
      @post.title.should == @post_json["title"]
      @post.user_id.should == @post_json["userId"]
      @post.body.should == @post_json["body"]
      prior_num_contexts.should == @c.contexts.count.should
    end
  end


  it "provides .merge! which will create a new resource if one doesn't already exist" do
    another_post = Post.create
    another_post.id = 10
    prior_num_contexts = @c.contexts.count
    another_post._save_single_resource_in_new_context({id: 2}) do |fetched_resource|
      fetched_resource.merge!.should == false
      another_post.id.should == 10
      another_post.title.should == nil
      another_post.user_id.should == nil
      another_post.body.should == nil
      prior_num_contexts.should == @c.contexts.count
    end
  end

  it "provides .merge_if(&block) { # true/false }" do
    higher_user_id = 100
    @post.user_id = higher_user_id
    @post._save_single_resource_in_new_context(@post_json) do |fetched_resource|
      fetched_resource.merge_if do
        fetched_resource.user_id > @post.user_id
      end.should == false
    end
    @post.id.should == 4
    @post.user_id.should == higher_user_id
    @post.title.should == nil
    @post.body.should == nil

    @post.user_id = 1
    @post_json["userId"] = higher_user_id
    @post._save_single_resource_in_new_context(@post_json) do |fetched_resource|
      fetched_resource.merge_if do
        fetched_resource.user_id > @post.user_id
      end.should == true
    end
    @post.id.should == 4
    @post.user_id.should == higher_user_id
    @post.title.should == @post_json["title"]
    @post.body.should == @post_json["body"]
  end

  it "generates its post parameters correctly" do
    @post.user_id = 10
    @post.post_parameters.should == {id: 4, userId: 10}
    @post.title = "Hello World"
    @post.post_parameters.should == {id: 4, userId: 10, title: "Hello World"}
  end

  it "provides ResourceClassName.fetch{ |conflicts| } for fetching collections and resolving conflicts" do
    local_post1 = @post.tap{ |lp1| lp1.id = 1; lp1.title = "LP1"}
    local_post2 = Post.create.tap{ |lp2| lp2.id = 2; lp2.title = "LP2 Title"}
    foreign_post2 = {"id" => 2, "title" => "FP2 Title"}
    foreign_post3 = {"id" => 3, "title" => "FP3 Title"}
    pretend_json = [foreign_post2, foreign_post3]
    fetch_params = {json: pretend_json}
    Post._compare_local_collection_to_fetched_collection(fetch_params) do |conflicts|
      conflicts.class.should == [].class
      conflicts.count.should == 2
      conflicts.first[:local].should == local_post2
      conflicts.first[:foreign].id.should == foreign_post2["id"]
      conflicts.first[:foreign].title.should == foreign_post2["title"]
      conflicts.last[:local].should == nil
      conflicts.last[:foreign].id.should == foreign_post3["id"]
      conflicts.last[:foreign].title.should == foreign_post3["title"]
    end
  end

  it "provides ResourceClassName.fetch_someHasManyRelatedResource for fetching has_many resources" do
    foreign_post2 = {"id" => 2, "title" => "FP2 Title"}
    foreign_post3 = {"id" => 3, "title" => "FP3 Title"}
    pretend_json = [foreign_post2, foreign_post3]
    user = User.create
    fetch_params = {json: pretend_json, owner_instance: user, relation_name: "user", related_model_class:Post}
    User._compare_local_collection_to_fetched_collection(fetch_params) do |conflicts|
      conflicts.each{ |c| c[:foreign].merge! }
    end
    user.posts.count.should == 2
  end

  # it translates key: :default to an integer increment that auto assigns 0,1,2,3,4
  #   also checks db for highest existing id and assigns next one (if 11 is in db, assigns 12)
end
