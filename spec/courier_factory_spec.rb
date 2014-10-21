describe "The Courier Factory" do
  before do
    if Object.constants.include?(:Person)
      Object.send(:remove_const, :Person)
    end
    if Object.constants.include?(:Thing)
      Object.send(:remove_const, :Thing)
    end
    Courier.nuke.everything.right.now
    class Person < Courier::Base
      has_many :things, as: :things, on_delete: :cascade, inverse_name: :owner
      property :name, String
      property :age, Integer16
    end

    class Thing < Courier::Base
      belongs_to :person, as: :owner, on_delete: :nullify, inverse_name: :things
      property :name, String
    end

    Courier::Courier.instance.parcels = [Person, Thing]
  end

  it "creates and persists models with Factory.create(:object, args_hash)" do
    nick = Courier::Factory.create(:person, name:"nick", age:22)
    Courier::Factory.create(:person, name:"chris", age:18)
    thing = Courier::Factory.create(:thing, name:"BopIt", owner:nick)
    Courier::Courier.instance.save

    Person.all.count.should == 2
    Thing.all.count.should == 1
    thing.owner.should == nick
  end
end
