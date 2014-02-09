describe "A Core Data StoreCoordinator Constructor" do
  behaves_like "A Core Data Spec"

  it "aliases .alloc.initWithManagedObjectModel(schema) to .new(schema)" do
    schema = CoreData::Schema.new
    lambda do
      store_coordinator = CoreData::StoreCoordinator.new(schema)
      store_coordinator.managedObjectModel.should == schema
    end.should.not.raise(StandardError)
  end

  describe "A Core Data StoreCoordinator" do
    before do
      @schema = CoreData::Schema.new
      @store_coordinator = CoreData::StoreCoordinator.new(@schema)
    end

    it "aliases .managedObjectModel to .schema" do
      real_schema = @store_coordinator.managedObjectModel
      lambda do
        real_schema.equal?(@store_coordinator.schema).should == true
      end.should.not.raise(StandardError)
    end

    it "aliases the '.persistentStores' getter to '.stores'" do
      real_stores = @store_coordinator.persistentStores
      lambda do
        real_stores.equal?(@store_coordinator.stores).should == true
      end.should.not.raise(StandardError)
    end

    it "creates stores with .add_store_named(\"default\")" do
      @store_coordinator.add_store_named("default")
      @store_coordinator.stores.count.should == 1
    end
  end
end
