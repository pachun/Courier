describe "A Core Data Model Instance" do
  behaves_like "A Core Data Spec"
  behaves_like "A Person Model Was Defined"

  before do
    @person_model = @context.create(Person)
  end

  it "is a descendant of CoreData::Model when generated through a context" do
    @person_model.class.ancestors.should.include(CoreData::Model)
  end

  it "inherits the behavior of the intended model" do
    @person_model.greet.should == "Hello"
  end

  it "aliases .managedObjectContext to .context" do
    @person_model.managedObjectContext.should == @context
    @person_model.context.should == @context
  end

  describe "The Core Data Model Class" do
    it "can discover it's model definition class given a context" do
      Person.model_definition(@context).should == @person_model_definition
    end

    it "has a .all_in_context(context) method to get all instances" do
      second_person = @context.create(Person)
      third_person = @context.create(Person)
      # @context.save # fetches all; saved or unsaved
      lambda do
        people = Person.all_in_context(@context)
        people.count.should == 3
        people.should.include(@person_model)
        people.should.include(second_person)
        people.should.include(third_person)
      end.should.not.raise(StandardError)
    end
  end
end
