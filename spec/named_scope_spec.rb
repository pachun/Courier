describe "A courier Named Scope" do
  before do

    # clean out last test's db
    Courier.nuke.everything.right.now
    if Object.constants.include?(:Person)
      Object.send(:remove_const, :Person)
    end

    # fixture data
    @old_age = 50
    @young_age = 30
    @people =
      [
        {name:"Nick",age:22},
        {name:"Alex", age:24},
        {name:"Thomas", age:29},
        {name:"Taylor", age:29},
        {name:"Joe", age:30},
        {name:"Jeremy",age:34},
        {name:"Mike", age:40},
        {name:"Mike's Dad",age:78},
      ]

    # restore fresh db
    @amazing_scope = {
      or: [
            {and: ["age > 30", "age < 50"]},
            "name is Nick",
      ]
    }

    class Person < Courier::Base
      property :id, Integer64
      property :age, Integer16
      property :name, String
      scope :old, "age > 50"
      scope :middle_aged, and: ["age > 30", "age < 50"]
      scope :middle_aged_or_amazing, {
        or: [
              {and: ["age > 30", "age < 50"]},
              "name is Nick",
        ]}
    end
    Courier::Courier.instance.parcels = [Person]

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

  it "works with NSComparisonPredicates" do
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

  it "works with NSCompoundPredicates" do
    not_young_predicate = Courier::Scope.where(:age, is_greater_than: @young_age)
    not_old_predicate = Courier::Scope.where(:age, is_less_than: @old_age)

    middle_aged = [
      not_young_predicate,
      not_old_predicate,
    ]
    middle_aged_predicate = Courier::Scope.and(middle_aged)

    fetch = NSFetchRequest.fetchRequestWithEntityName("Person")
    fetch.setPredicate(middle_aged_predicate)
    error = Pointer.new(:object)
    results = Courier::Courier.instance.contexts[:main].executeFetchRequest(fetch, error:error)
    results.count.should == \
      @people.select{ |p| p[:age] > @young_age && p[:age] < @old_age }.count
  end

  it "works in string form with a single predicate" do
    old_people = Person.old
    old_people.count.should == \
      @people.select{ |p| p[:age] > @old_age }.count
  end

  it "works in string form with a mutliple predicates" do
    old_people = Person.middle_aged
    old_people.count.should == \
      @people.select{ |p| p[:age] > @young_age && p[:age] < @old_age }.count
  end

  it "works with more complex nestings of predicates" do
    some_people = Person.middle_aged_or_amazing
    some_people.count.should == \
      @people.select do |p|
        (p[:age] > @young_age && p[:age] < @old_age) || p[:name] == "Nick"
      end.count
  end
end
