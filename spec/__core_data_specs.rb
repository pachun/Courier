shared "A Core Data Spec" do
  before do
    app_documents_path = NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).last
    default_store_url = app_documents_path.URLByAppendingPathComponent("default.sqlite")
    NSFileManager.defaultManager.removeItemAtPath(default_store_url, error:nil)
  end
end

shared "A Person Model Was Defined" do
  before do
    @person_model_definition = CoreData::ModelDefinition.new
    @person_model_definition.name = "Person"

    person_id = CoreData::PropertyDefinition.new
    person_id.name = "id"
    person_id.type = CoreData::PropertyTypes::Integer32

    person_name = CoreData::PropertyDefinition.new
    person_name.name = "name"
    person_name.type = CoreData::PropertyTypes::String

    @person_model_definition.properties = [person_id, person_name]

    class Person < CoreData::Model
      def greet; "Hello"; end
    end
    @person_model_definition.model = Person

    @schema = CoreData::Schema.new
    @schema.entities = [@person_model_definition]
    @store_coordinator = CoreData::StoreCoordinator.new(@schema)
    @store_coordinator.add_store_named("default")

    @context = CoreData::Context.new
    @context.store_coordinator = @store_coordinator
  end
end
