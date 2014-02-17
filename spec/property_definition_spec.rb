describe "A Core Data PropertyDefinition" do
  before do
    @property_definition = CoreData::PropertyDefinition.new
  end

  it "is a descendant of NSAttributeDescription" do
    @property_definition.class.ancestors.should.include(NSAttributeDescription)
  end

  it "aliases the 'attributeType' property accessors to 'type'" do
    string_type = CoreData::PropertyTypes::String
    lambda do
      @property_definition.type = string_type
      @property_definition.type.should == string_type
      @property_definition.attributeType.should == string_type
    end.should.not.raise(StandardError)
  end

  it "aliases the 'defaultValue' property accessors to 'default_value'" do
    default_value = 5
    lambda do
      @property_definition.default_value = default_value
      @property_definition.default_value.should == default_value
      @property_definition.defaultValue.should == default_value
    end.should.not.raise(StandardError)
  end

  it "provides a .same_as?(another_property) method" do
    another_property = CoreData::PropertyDefinition.new
    @property_definition.same_as?(another_property).should == true
    another_property.type = CoreData::PropertyTypes::Integer64
    @property_definition.same_as?(another_property).should == false
  end
end
