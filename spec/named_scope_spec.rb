describe "Courier Named Scopes" do
  before do

    # clean out last test's db
    Courier.nuke.everything.right.now
    if Object.constants.include?(:Person)
      Object.send(:remove_const, :Person)
    end

    # restore fresh db
    class Person < Courier::Base
      property :id, Integer64
      property :age, Integer16
      property :name, String
    end
    Courier::Courier.instance.parcels = [Person]

    # fixture data
    @people =
      [
        {name:"Nick",age:22},
        {name:"Alex", age:24},
        {name:"Thomas", age:29},
        {name:"Taylor", age:29},
        {name:"Joe", age:30},
        {name:"Jeremy",age:34},
        {name:"Mike", age:40},
        {name:"Father Time",age:78},
      ]
    @old_age = 50
    @young_age = 30

    # save fixtures
    @people.each_with_index do |d, i|
      Person.create.tap do |p|
        p.id = i
        p.name = d[:name]
        p.age = d[:age]
      end
    end
    Courier::Courier.instance.save
  end

  it "Work with NSComparisonPredicates" do
    old_people_scope = Courier::Scope.where(:age, is_greater_than_or_equal_to: @old_age)
    Person.where( old_people_scope ).count.should == \
      @people.select{ |p| p[:age] >= @old_age }.count
    old_people_scope = Courier::Scope.where(:age, is_greater_than_or_equal_to: @old_age)
    Person.where( old_people_scope ).count.should == \
      @people.select{ |p| p[:age] >= @old_age }.count
    old_people_scope = Courier::Scope.where(:age, is_greater_than_or_equal_to: @old_age)
    Person.where( old_people_scope ).count.should == \
      @people.select{ |p| p[:age] >= @old_age }.count
  end

  it "Work with NSCompoundPredicates" do
    not_young_predicate = NSPredicate.predicateWithFormat("age > #{@young_age}")
    not_old_predicate = NSPredicate.predicateWithFormat("age < #{@old_age}")

    middle_aged = [
      not_young_predicate,
      not_old_predicate,
    ]
    middle_aged_predicate = Courier::Scope.and(middle_aged)

    fetch = NSFetchRequest.fetchRequestWithEntityName("Person")
    fetch.setPredicate(middle_aged_predicate)
    error = Pointer.new(:object)
    results = Courier::Courier.instance.contexts[:main].executeFetchRequest(fetch, error:error)
    results.count.should == @people.select{ |p| p[:age] > @young_age && p[:age] < @old_age }.count
  end
end
