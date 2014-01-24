describe "A Core Data Relationship Definition" do
  before do
    @relationship = CoreData::RelationshipDefinition.new
  end
  it "is a descendant of NSRelationshipDescription" do
    @relationship.class.ancestors.should.include(NSRelationshipDescription)
  end

  it "aliases the destinationEntity accessors to destination_model" do
    model_definition = CoreData::ModelDefinition
    lambda do
      @relationship.destination_model = model_definition
      @relationship.destinationEntity.should == model_definition
      @relationship.destination_model.should == model_definition
    end.should.not.raise(StandardError)
  end

  it "aliases the inverseRelationship accessors to inverse_relationship" do
    model_definition = CoreData::ModelDefinition
    inverse_relationship = CoreData::RelationshipDefinition.new
    lambda do
      @relationship.inverse_relationship = inverse_relationship
      @relationship.inverseRelationship.should == inverse_relationship
      @relationship.inverse_relationship.should == inverse_relationship
    end.should.not.raise(StandardError)
  end
end
