describe "Courier Named Scopes" do
  before do
    Courier.nuke.everything.right.now
    if Object.constants.include?(:Person)
      Object.send(:remove_const, :Person)
    end

    class Person < Courier::Base
      property :id, Integer64
      property :age, Integer16
      property :name, String

      scope :old, and: ["age >= 30", "name == nick"]
    end
    Courier::Courier.instance.parcels = [Person]
  end

  it "works with no nested predicates" do
    [{name:"nick",age:22},{name:"Jeremy",age:32}].each_with_index do |d, i|
      Person.create.tap do |p|
        p.id = i
        p.name = d[:name]
        p.age = d[:age]
      end
    end
    Courier::Courier.instance.save
    puts "IM HERE!!"
    true.should == true
    Person.old.count.should == 1
  end
end
