shared "A Core Data Spec" do
  before do
    Courier::nuke.everything.right.now
    # app_documents_path = NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).last
    # default_store_url = app_documents_path.URLByAppendingPathComponent("default.sqlite")
    # courier_store_url = app_documents_path.URLByAppendingPathComponent("courier.sqlite")
    # [default_store_url, courier_store_url, Packager.URL(Courier::MigrationLogSaveName).path, Packager.URL(Courier::SchemaSaveName).path].each do |url|
    #   NSFileManager.defaultManager.removeItemAtPath(url, error:nil)
    # end
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
    @store_coordinator = Courier::StoreCoordinator.new(@schema)
    @store_coordinator.build

    @context = CoreData::Context.new
    @context.store_coordinator = @store_coordinator
  end
end
