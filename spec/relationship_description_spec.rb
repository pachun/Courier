describe "The Core Data Relationship Description Class" do
  before do
    class Channel < CoreData::Model; end
    @name = "channels"
    @destination_model = Channel
    @delete_rule = CoreData::DeleteRule::Cascade
    @max_count = 0
    @min_count = 0

    channels_relationship = CoreData::RelationshipDefinition.new
    channels_relationship.name = @name
    channels_relationship.destination_model = @destination_model
    channels_relationship.delete_rule = @delete_rule
    channels_relationship.max_count = @max_count
    channels_relationship.min_count = @min_count

    @channels_relationship_description = CoreData::RelationshipDescription.new(channels_relationship)
  end

  it "persists name, destination_model, delete_rule, max_count, and min_count" do
    @channels_relationship_description.name.should == @name
    @channels_relationship_description.destination_model.should == @destination_model.to_s
    @channels_relationship_description.delete_rule.should == @delete_rule
    @channels_relationship_description.min_count.should == @min_count
    @channels_relationship_description.max_count.should == @max_count
  end

  it "describes itself properly" do
    relationship_type = CoreData::RelationshipDescription.type_string(@min_count, @max_count)
    delete_rule = CoreData::RelationshipDescription.delete_string(@delete_rule)
    @channels_relationship_description.describe.should == \
      "    #{@destination_model.to_s} (#{relationship_type}) => #{delete_rule}\n"
  end
end
