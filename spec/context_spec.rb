describe "A New Core Data Context" do
  behaves_like "A Core Data Spec"

  it "is a descendant of NSManagedObjectContext" do
    context = CoreData::Context.new
    context.class.ancestors.should.include(NSManagedObjectContext)
  end

  it "aliases 'persistentStoreCoordinator' property accessors to 'store_coordinator'" do
    context = CoreData::Context.new
    schema = CoreData::Schema.new
    intended_store_coordinator = CoreData::StoreCoordinator.new(schema)
    lambda do
      context.store_coordinator = intended_store_coordinator
      real_store_coordinator = context.persistentStoreCoordinator
      real_store_coordinator.equal?(context.store_coordinator).should == true
    end.should.not.raise(StandardError)
  end

  describe "A Core Data Context with Models Defined in the Schema" do
    behaves_like "A Person Model Was Defined"

    it "creates a .create(ModelName) factory method for generating objects" do
      lambda do
        person = @context.create(Person)
        person.class.ancestors.should.include(NSManagedObject)
      end.should.not.raise(StandardError)
    end

    it "saves models with .save" do
      person = @context.create(Person)
      lambda do
        @context.save.should == true
      end.should.not.raise(StandardError)
    end
  end
end
