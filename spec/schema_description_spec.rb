describe "The Core Data Schema Description Class" do
  before do
    @person_model = CoreData::ModelDefinition.new
    @person_model.name = "Person"
    @person_model.model = Person

    @toy_model = CoreData::ModelDefinition.new
    @toy_model.name = "Toy"
    @toy_model.model = Toy

    owner = CoreData::RelationshipDefinition.new
    owner.name = "owner"
    owner.destination_model = @person_model
    owner.min_count = 0
    owner.max_count = 1
    owner.delete_rule = CoreData::DeleteRule::Nullify

    toys = CoreData::RelationshipDefinition.new
    toys.name = "toys"
    toys.destination_model = @toy_model
    toys.min_count = 0
    toys.max_count = 0
    toys.delete_rule = CoreData::DeleteRule::Cascade

    owner.inverse_relationship = toys
    toys.inverse_relationship = owner

    toy_name = CoreData::PropertyDefinition.new
    toy_name.name = "name"
    toy_name.type = CoreData::PropertyTypes::String

    person_name = CoreData::PropertyDefinition.new
    person_name.name = "name"
    person_name.type = CoreData::PropertyTypes::String

    @toy_model.properties = [toy_name, owner]
    @person_model.properties = [person_name, toys]

    @schema = CoreData::Schema.new
    @schema.entities = [@person_model, @toy_model]
    @schema_description = CoreData::SchemaDescription.new(@schema)

    @person_description = CoreData::ModelDescription.new(@person_model)
    @toy_description = CoreData::ModelDescription.new(@toy_model)
  end

  it "persists all model definitions" do
    model_descriptions = @schema_description.model_descriptions
    model_descriptions.count.should == 2
  end

  it "describes itself properly" do
    @schema_description.describe.should == \
      "\nSchema\n======\n#{@toy_description.describe}\n#{@person_description.describe}\n"
  end

  it "can save and reconstruct itself through NSCoder via Packager" do
    handle = @schema_description.save
    rebuilt = CoreData::SchemaDescription.load(handle)
    rebuilt.model_descriptions.count.should == 2
    rebuilt.describe.should == \
      "\nSchema\n======\n#{@toy_description.describe}\n#{@person_description.describe}\n"
  end

  it "has .to_schema to get back CoreData::Schema" do
    original_schema = @schema_description.to_schema
    original_schema.entities.count.should == @schema.entities.count
  end
end
