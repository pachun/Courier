describe "The Core Data Relationship Description Class" do
  before do
    class Channel < CoreData::Model; end
    @name = "channels"
    @destination_model = Channel
    @delete_rule = CoreData::DeleteRule::Cascade
    @max_count = 0
    @min_count = 0
    @inverse_id = CoreData::RelationshipDefinition.random_inverse_id

    @channels_relationship = CoreData::RelationshipDefinition.new
    @channels_relationship.name = @name
    @channels_relationship.destination_model = @destination_model
    @channels_relationship.delete_rule = @delete_rule
    @channels_relationship.max_count = @max_count
    @channels_relationship.min_count = @min_count
    @channels_relationship.inverse_id = @inverse_id

    @channels_relationship_description = CoreData::RelationshipDescription.new(@channels_relationship)
  end

  it "persists name, destination_model, delete_rule, max_count, min_count, and inverse_id" do
    @channels_relationship_description.name.should == @name
    @channels_relationship_description.destination_model.should == @destination_model.to_s
    @channels_relationship_description.delete_rule.should == @delete_rule
    @channels_relationship_description.min_count.should == @min_count
    @channels_relationship_description.max_count.should == @max_count
    @channels_relationship_description.inverse_id.should == @inverse_id
  end

  it "describes itself properly" do
    relationship_type = CoreData::RelationshipDescription.type_string(@min_count, @max_count)
    dest_model = @destination_model.to_s.downcase.pluralize
    delete_rule = CoreData::RelationshipDescription.delete_string(@delete_rule)
    @channels_relationship_description.describe.should == \
      "    #{relationship_type} #{dest_model} through .#{@name} (#{delete_rule})\n"
  end

  it "can save and reconstruct itself through NSCoder via Packager" do
    handle = @channels_relationship_description.save
    rebuilt = CoreData::RelationshipDescription.load(handle)
    rebuilt.name.should == @name
    rebuilt.destination_model.should == @destination_model.to_s
    rebuilt.delete_rule.should == @delete_rule
    rebuilt.min_count.should == @min_count
    rebuilt.max_count.should == @max_count
    rebuilt.inverse_id.should == @inverse_id
  end

  it "has .to_definition to get back the CoreData::RelationshipDefinition" do
    definition = @channels_relationship_description.to_definition
    definition.name.should == @channels_relationship.name
    definition.destination_model.should == @channels_relationship.destination_model.to_s
    definition.delete_rule.should == @channels_relationship.delete_rule
    definition.min_count.should == @channels_relationship.min_count
    definition.max_count.should == @channels_relationship.max_count
    definition.inverse_id.should == @channels_relationship.inverse_id
  end
end
