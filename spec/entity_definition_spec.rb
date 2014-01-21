describe "CoreData::EntityDefinition" do
  before do
    @entity_definition = CoreData::EntityDefinition.new
  end

  it "is a descendant of NSEntityDescription" do
    @entity_definition.class.ancestors.should.include(NSEntityDescription)
  end

  it "aliases the 'managedObjectClassName' property accessors to 'model' which accepts AClassName instead of a \"string\"" do
    lambda do
      class Person; end
      my_model = Person
      @entity_definition.model = my_model
      @entity_definition.model.should == my_model.to_s
      @entity_definition.managedObjectClassName.should == my_model.to_s
    end.should.not.raise(StandardError)
  end
end
