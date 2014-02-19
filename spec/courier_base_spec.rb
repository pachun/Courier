describe "The Courier Base Class" do
  behaves_like "A Core Data Spec"

  before do
    if Object.constants.include?(:Keyboard)
      Object.send(:remove_const, :Keyboard)
    end
    if Object.constants.include?(:Key)
      Object.send(:remove_const, :Key)
    end

    class Key < Courier::Base
      belongs_to :keyboard, as: :keyboard, on_delete: :nullify
    end

    class Keyboard < Courier::Base
      has_many :keys, as: :keys, on_delete: :cascade
      property :brand, String, required: true, default: "Dell"
      property :lbs, Integer16
    end
    Courier::Courier.instance.parcels = [Keyboard, Key]
  end

  it "is a descendant of CoreData::Model" do
    Keyboard.ancestors.should.include(CoreData::Model)
  end

  it "defines a .to_coredata class method to return the Core Data model definition" do
    coredata_class = Keyboard.to_coredata
    coredata_class.class.should == CoreData::ModelDefinition
    coredata_class.name.should == Keyboard.to_s
    coredata_class.model.should == Keyboard.to_s
    coredata_class.properties.count.should == 3
    property_types = coredata_class.properties.map{ |p| p.class }
    property_types.select{ |p| p == CoreData::PropertyDefinition }.count.should == 2
    property_types.select{ |p| p == CoreData::RelationshipDefinition }.count.should == 1
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

  it "defaults property.optional to false and property.default_value to nil" do
    lbs_property = Keyboard.to_coredata.properties.select{ |p| p.name == "lbs" }.first
    lbs_property.optional?.should == true
    lbs_property.default_value.should == nil
  end

  it "sets required and default_value using opts in: property(name, type, opts={})" do
    brand_property = Keyboard.to_coredata.properties.select{ |p| p.name == "brand" }.first
    brand_property.optional?.should == false
    brand_property.default_value.should == "Dell"
  end

  it "should return an unfrozen array of Key objects on keyboard.keys (not a faulting segment)" do
    keyboard = Keyboard.create
    key1 = Key.create
    key2 = Key.create
    key1.keyboard = keyboard
    key2.keyboard = keyboard
    all_keys = keyboard.keys
    all_keys.frozen?.should == false
    lambda{ all_keys << "hello" }.should.not.raise(StandardError)
    all_keys.class.should == [].class
    all_keys.should.include(key1)
    all_keys.should.include(key2)
  end

  it "provides .true_class to get ClassName instead of ClassName_Classname_" do
    keyboard = Keyboard.create
    keyboard.true_class.should == Keyboard
  end

  it "provides keyboard << key to add a key to a keyboard if keyboard has many keys" do
    keyboard = Keyboard.create
    key1 = Key.create
    key2 = Key.create
    key1.keyboard = keyboard
    lambda{ keyboard << key2 }.should.not.raise(StandardError)
    all_keys = keyboard.keys
    all_keys.class.should == [].class
    all_keys.should.include(key1)
    all_keys.should.include(key2)
  end

  it "provides a .delete that obeys the relationships defined delete rule" do
    apple_keyboard = Keyboard.create
    apple_keyboard << Key.create
    apple_keyboard.keys.last.delete
    apple_keyboard.save
    apple_keyboard.keys.count.should == 0
    lambda{ apple_keyboard.keys }.should.not.raise(StandardError) # nullify works

    das_keyboard = Keyboard.create
    das_keyboard << Key.create
    das_keyboard << Key.create
    das_keyboard.delete
    das_keyboard.save
    Key.all.count.should == 0 # cascade works
  end

  # it "defines .where() the returns an NSPredicate" do
  # end
end
