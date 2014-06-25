describe "The Courier Class" do
  before do
    Object.send(:remove_const, :Cup) if Object.constants.include?(:Cup)
    Object.send(:remove_const, :Plate) if Object.constants.include?(:Plate)
    Courier::nuke.everything.right.now
    class Cup < Courier::Base; end
    class Plate < Courier::Base; end
    @courier = Courier::Courier.instance
    @courier.parcels = [Cup, Plate]
  end

  it "defines a singleton reachable at .instance" do
    @courier.class.should == Courier::Courier
  end

  it "builds a schema and create a main context when .parcels=[m1,m2,etx] are set" do
    @courier.contexts[:main].class.should == CoreData::Context
  end

  it "keeps track of a url for fetching remote resources" do
    url = "pachulski.me"
    @courier.url = url
    @courier.url.should == url
  end

  it "avoids naming collisions among context keys in the contexts hash" do
    p1 = Plate.create_in_new_context
    p2 = Plate.create_in_new_context
    @courier.contexts.keys.count.should == 3
    p1.delete!
    p3 = Plate.create_in_new_context
    @courier.contexts.count.should == 3
  end

  # it "deletes all the /documents on .nuke.everything.right.now" do
  #   file_manager = NSFileManager.defaultManager
  #   app_documents_path = file_manager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).last
  #   file_paths = file_manager.contentsOfDirectoryAtPath(app_documents_path, error:nil)
  #   file_paths.count.should.be > 0
  #   Courier.nuke.everything.right.now.should == true
  #   file_paths = file_manager.contentsOfDirectoryAtPath(app_documents_path, error:nil)
  #   file_paths.count.should == 0
  # end
end
