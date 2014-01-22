shared "A Core Data Spec" do
  before do
    app_documents_path = NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).last
    default_store_url = app_documents_path.URLByAppendingPathComponent("default.sqlite")
    NSFileManager.defaultManager.removeItemAtPath(default_store_url, error:nil)
  end
end

describe "CoreData::Context" do
  behaves_like "A Core Data Spec"

  before do
    @context = CoreData::Context.new
  end

  it "is a descendant of NSManagedObjectContext" do
    @context.class.ancestors.should.include(NSManagedObjectContext)
  end

  it "aliases 'persistentStoreCoordinator' property accessors to 'store_coordinator'" do
    schema = CoreData::Schema.new
    intended_store_coordinator = CoreData::StoreCoordinator.new(schema)
    lambda do
      @context.store_coordinator = intended_store_coordinator
      real_store_coordinator = @context.persistentStoreCoordinator
      real_store_coordinator.equal?(@context.store_coordinator).should == true
    end.should.not.raise(StandardError)
  end

  it "creates a .create(entity_type) factory method for generating objects" do
    class Person < NSManagedObject; end
    person_entity = CoreData::ModelDefinition.new
    person_entity.name = "Person"
    person_entity.model = Person

    @schema = CoreData::Schema.new
    @schema.entities = [person_entity]
    @store_coordinator = CoreData::StoreCoordinator.new(@schema)
    @store_coordinator.add_default_store

    @context.store_coordinator = @store_coordinator
    lambda do
      person = @context.create(Person)
      person.class.ancestors.should.include(NSManagedObject)
    end.should.not.raise(StandardError)
  end
end
