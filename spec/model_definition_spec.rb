describe "A Core Data ModelDefinition" do
  before do
    @model_definition = CoreData::ModelDefinition.new
  end

  it "is a descendant of NSEntityDescription" do
    @model_definition.class.ancestors.should.include(NSEntityDescription)
  end

  it "aliases the 'managedObjectClassName' property accessors to 'model' which accepts AClassName instead of a \"string\"" do
    lambda do
      class Person; end
      my_model = Person
      @model_definition.model = my_model
      @model_definition.model.should == my_model.to_s
      @model_definition.managedObjectClassName.should == my_model.to_s
    end.should.not.raise(StandardError)
  end
end
