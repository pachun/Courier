describe "CoreData::StoreCoordinator Constructor" do
  behaves_like "A Core Data Spec"

  it "aliases .alloc.initWithManagedObjectModel(schema) to .new(schema)" do
    schema = CoreData::Schema.new
    lambda do
      store_coordinator = CoreData::StoreCoordinator.new(schema)
      store_coordinator.managedObjectModel.should == schema
    end.should.not.raise(StandardError)
  end

  describe "CoreData::StoreCoordinator" do
    before do
      @schema = CoreData::Schema.new
      @store_coordinator = CoreData::StoreCoordinator.new(@schema)
    end

    it "aliases the '.persistentStores' getter to '.stores'" do
      real_stores = @store_coordinator.persistentStores
      lambda do
        real_stores.equal?(@store_coordinator.stores).should == true
      end.should.not.raise(StandardError)
    end

    it "creates a default.sqlite db when sent .add_default_store" do
      @store_coordinator.add_default_store
      @store_coordinator.persistentStores.count.should == 1
    end
  end
end
