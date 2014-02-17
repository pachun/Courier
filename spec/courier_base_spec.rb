describe "The Courier Base Class" do
  behaves_like "A Core Data Spec"

  before do
    if Object.constants.include?(:Keyboard)
      Object.send(:remove_const, :Keyboard)
    end

    class Key < Courier::Base
      # belongs_to :keyboard, on_delete: :nullify
    end

    class Keyboard < Courier::Base
      # has_many :keys, on_delete: :cascade
      property :brand, CoreData::PropertyTypes::String
      property :lbs, CoreData::PropertyTypes::Integer16
    end
    Courier::Courier.instance.parcels = [Keyboard]
  end

  it "is a descendant of CoreData::Model" do
    Keyboard.ancestors.should.include(CoreData::Model)
  end

  it "defines a .to_coredata class method to return the Core Data model definition" do
    coredata_class = Keyboard.to_coredata
    coredata_class.class.should == CoreData::ModelDefinition
    coredata_class.name.should == Keyboard.to_s
    coredata_class.model.should == Keyboard.to_s
    coredata_class.properties.count.should == 2
  end

  it "initializes itself with .create" do
    lambda do
      keyboard = Keyboard.create
    end.should.not.raise(StandardError)
  end

  it "provides a .all method to fetch all Keyboards" do
    keyboard1 = Keyboard.create
    Keyboard.all.count.should == 1
    Keyboard.all.should.include(keyboard1)
    keyboard2 = Keyboard.create
    Keyboard.all.count.should == 2
    Keyboard.all.should.include(keyboard2)
  end

  it "sets and retrieves properties as expected" do
    lambda do
      keyboard = Keyboard.create
      keyboard.brand = "Das"
      keyboard.lbs = 6
      keyboard.brand.should == "Das"
      keyboard.lbs.should == 6
    end.should.not.raise(StandardError)
  end

  it "provides a .save method for multiple-app-run persistence" do
    keyboard = Keyboard.create
    keyboard.brand = "Das"
    keyboard.lbs = 6
    lambda{ keyboard.save }.should.not.raise(StandardError)
  end
end
