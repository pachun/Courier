describe "The Core Data Model Description Class" do
  before do
    class Phone < CoreData::Model; end
    class Contact < CoreData::Model; end

    @name = "Phone"
    @model = Phone
    @relationship_name = "Contact"
    @relationship_model = Contact

    @phone_model = CoreData::ModelDefinition.new
    @phone_model.name = @name
    @phone_model.model = @model

    contact_model = CoreData::ModelDefinition.new
    contact_model.name = @relationship_name
    contact_model.model = @relationship_model

    @contacts_relationship = CoreData::RelationshipDefinition.new
    @contacts_relationship.name = "contacts"
    @contacts_relationship.destination_model = contact_model
    @contacts_relationship.min_count = 0
    @contacts_relationship.max_count = 0
    @contacts_relationship.delete_rule = CoreData::DeleteRule::Cascade

    @number_property = CoreData::PropertyDefinition.new
    @number_property.name = "number"
    @number_property.type = CoreData::PropertyTypes::String

    @phone_model.properties = [@number_property, @contacts_relationship]

    @phone_model_description = CoreData::ModelDescription.new(@phone_model)
  end

  it "persists name, model, properties, and relationships" do
    @phone_model_description.name.should == @name
    @phone_model_description.model.should == @model.to_s
    @phone_model_description.properties.count.should == 1
    @phone_model_description.relationships.count.should == 1
  end

  it "describes itself properly" do
    contact_desc = CoreData::RelationshipDescription.new(@contacts_relationship)
    number_desc = CoreData::PropertyDescription.new(@number_property)
    @phone_model_description.describe.should == \
      "  #{name}\n#{contact_desc.describe}#{number_desc.describe}"
  end

  it "can save and reconstruct itself through NSCoder via Packager" do
    handle = @phone_model_description.save
    rebuilt = CoreData::ModelDescription.load(handle)
    rebuilt.name.should == @name
    rebuilt.model.should == @model.to_s
    rebuilt.properties.count.should == 1
    rebuilt.relationships.count.should == 1
  end

  it "has .to_definition to get back the CoreData::ModelDefinition" do
    definition = @phone_model_description.to_definition
    definition.name.should == @phone_model.name
    definition.model.should == @phone_model.model.to_s
    definition.properties.count.should == @phone_model.properties.count
  end
end
