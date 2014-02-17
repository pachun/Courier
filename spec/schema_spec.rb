describe "A Core Data Schema" do
  before do
    @schema = CoreData::Schema.new
  end

  it "is a descendant of NSManagedObjectModel" do
    @schema.class.ancestors.should.include(NSManagedObjectModel)
  end

  it "provides a .same_as?(another_model_definition) method" do
    another_schema = CoreData::Schema.new
    @schema.same_as?(another_schema).should == true

    another_schema.entities = [
      CoreData::ModelDefinition.new.tap{ |p| p.name = "Candle" }
    ]
    @schema.same_as?(another_schema).should == false
  end
end
