describe "CoreData::Context" do
  before do
    @context = CoreData::Context.new
  end

  it "is a descendant of NSManagedObjectContext" do
    @context.class.ancestors.should.include(NSManagedObjectContext)
  end

  it "aliases 'persistentStoreCoordinator' property accessors to 'store_coordinator'" do
    schema = CoreData::Schema.new
    intended_coordinator = CoreData::StoreCoordinator.new(schema)
    lambda do
      @context.store_coordinator = intended_coordinator
      @context.store_coordinator.should == intended_coordinator

      real_store_coordinator = @context.persistentStoreCoordinator
      real_store_coordinator.equal?(@context.store_coordinator).should == true
    end.should.not.raise(StandardError)
  end
end
