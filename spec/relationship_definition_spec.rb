describe "A Core Data Relationship Definition" do
  before do
    @relationship = CoreData::RelationshipDefinition.new
  end

  it "is a descendant of NSRelationshipDescription" do
    @relationship.class.ancestors.should.include(NSRelationshipDescription)
  end

  it "aliases the destinationEntity accessors to destination_model" do
    intended_destination_model = CoreData::ModelDefinition.new
    lambda do
      @relationship.destination_model = intended_destination_model
      @relationship.destination_model.equal?(intended_destination_model).should == true
      @relationship.destinationEntity.equal?(intended_destination_model).should == true
    end.should.not.raise(StandardError)
  end

  it "aliases the inverseRelationship accessors to inverse_relationship" do
    inverse_relationship = CoreData::RelationshipDefinition.new
    lambda do
      @relationship.inverse_relationship = inverse_relationship
      @relationship.inverse_relationship.equal?(inverse_relationship).should == true
      @relationship.inverseRelationship.equal?(inverse_relationship).should == true
    end.should.not.raise(StandardError)
  end

  it "sets the same @inverse_id on both relationships when an inverse is set" do
    inverse_relationship = CoreData::RelationshipDefinition.new
    @relationship.inverse_relationship = inverse_relationship
    inverse_relationship.inverse_relationship = @relationship
    @relationship.inverse_id.should.not.be.nil
    @relationship.inverse_id.should == inverse_relationship.inverse_id
  end

  it "aliases the deleteRule accessors to delete_rule" do
    delete_rule = CoreData::DeleteRule::Cascade
    lambda do
      @relationship.delete_rule = delete_rule
      @relationship.delete_rule.should == delete_rule
      @relationship.deleteRule.should == delete_rule
    end.should.not.raise(StandardError)
  end

  it "aliases the maxCount accessors to max_count" do
    max = 5
    lambda do
      @relationship.max_count = max
      @relationship.max_count.should == max
      @relationship.maxCount.should == max
    end.should.not.raise(StandardError)
  end

  it "aliases the minCount accessors to min_count" do
    min = 2
    lambda do
      @relationship.min_count = min
      @relationship.min_count.should == min
      @relationship.minCount.should == min
    end.should.not.raise(StandardError)
  end

  it "keeps track of the inverse relationship's name as inverse_name" do
    @relationship.inverse_name = "some_name"
    @relationship.inverse_name.should == "some_name"
  end

  it "provides a .same_as?(another_relationship) method" do
    another_relationship = CoreData::RelationshipDefinition.new
    @relationship.same_as?(another_relationship).should == true
    another_relationship.max_count = 1
    @relationship.same_as?(another_relationship).should == false
  end
end
