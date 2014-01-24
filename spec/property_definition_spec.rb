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
end
