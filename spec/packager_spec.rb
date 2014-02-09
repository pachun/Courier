def file_path(name)
  app_documents_path = NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).last
  app_documents_path.URLByAppendingPathComponent(name)
end

describe "The Packager Module" do
  before do
    class Player
      include Packager
      attr_accessor :name, :age, :team
    end
    @player = Player.new
  end

  it "saves all attr_accessor variables in packager_attributes" do
    @player.packager_attributes.sort.should == [:name, :age, :team].sort
  end

  it "defines working .save and .load methods" do
    player = Player.new
    player.name = "Martin Brodeur"
    player.age = 41
    player.team = "New Jersey Devils"
    handle = player.save("Hello World")
    handle.should.not.be.false
    same_player = Player.load(handle)
    same_player.class.should == Player
    same_player.name.should == "Martin Brodeur"
    same_player.age.should == 41
    same_player.team.should == "New Jersey Devils"
    same_player.packager_url.absoluteString.split("/").last.split("%20").join(" ").should == handle
  end
end
