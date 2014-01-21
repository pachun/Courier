describe "CoreData::Schema" do
  before do
    @schema = CoreData::Schema.new
  end

  it "is a descendant of NSManagedObjectModel" do
    @schema.class.ancestors.should.include(NSManagedObjectModel)
  end
end
