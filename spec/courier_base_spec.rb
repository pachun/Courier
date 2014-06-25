describe "The Courier Base Class" do
  behaves_like "A Core Data Spec"

  before do
    if Object.constants.include?(:Keyboard)
      Object.send(:remove_const, :Keyboard)
    end
    if Object.constants.include?(:Key)
      Object.send(:remove_const, :Key)
    end
    if Object.constants.include?(:Marking)
      Object.send(:remove_const, :Marking)
    end

    class Keyboard < Courier::Base
      has_many :keys, as: :keys, on_delete: :cascade
      has_many :keyboard_markings, through: [:keys, :markings]

      property :brand, String, required: true, default: "Dell"
      property :lbs, Integer16

      attr_accessor :not_persisted1, :not_persisted2

      scope :heavy_plain, Courier::Scope.where(:lbs, is_greater_than_or_equal_to:4)
      scope :heavy_fancified, :and => ["lbs >= 4", "name = Das"]

      self.json_to_local = {brand_name: :brand, weight_in_pounds: :lbs}
      self.individual_path = "keyboards/:brand"
      self.collection_path = "keyboards"
    end

    class Key < Courier::Base
      belongs_to :keyboard, as: :keyboard, on_delete: :nullify
      has_many :markings, as: :markings, on_delete: :cascade
    end

    class Marking < Courier::Base
      belongs_to :key, as: :key, on_delete: :nullify
    end

    Courier::Courier.instance.parcels = [Keyboard, Key, Marking]
    Courier::Courier.instance.url = "xyz.com"
  end

  it "correctly calculates an instances individual URL (accounting for potential trailing slash on the base url" do
    k = Keyboard.create
    k.brand = "Das"
    k.individual_url.should == "xyz.com/keyboards/Das"
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

  it "provides a Class.where() which takes an NSPredicate" do
    apple_keyboard = Keyboard.create.tap do |k|
      k.brand = "Das"
      k.lbs = 1
    end
    das_keyboard = Keyboard.create.tap do |k|
      k.brand = "Apple"
      k.lbs = 5
    end
    Courier::Courier.instance.contexts[:main].save
    scope = Courier::Scope.where(:brand, is_any_of: ["Apple", "Das2.0"])
    results = Keyboard.where(scope)
    results.count.should == 1
  end

  it "provides an instance.where() which takes an NSPredicate" do
    apple_keyboard = Keyboard.create.tap do |k|
      k.brand = "Das"
      k.lbs = 5
    end
    das_keyboard = Keyboard.create.tap do |k|
      k.brand = "Apple"
      k.lbs = 1
    end
    Courier::Courier.instance.contexts[:main].save
    scope = Courier::Scope.where(:lbs, is_greater_than: 3)
    all_keyboards = Keyboard.all.where(scope)
    all_keyboards.count.should == 1
  end

  it "has working named scopes" do
    apple_keyboard = Keyboard.create.tap do |k|
      k.brand = "Das"
      k.lbs = 5
    end
    das_keyboard = Keyboard.create.tap do |k|
      k.brand = "Apple"
      k.lbs = 1
    end
    Courier::Courier.instance.contexts[:main].save
    Keyboard.scopes.count.should == 2
    Keyboard.heavy_plain.count.should == 1
    # Keyboard.heavy_fancified.count.should == 1
  end

  it "has working has_many:through:as: relationships" do
    kb1 = Keyboard.create
    key1 = Key.create
    key2 = Key.create
    kb1 << key1
    kb1 << key2
    m1 = Marking.create
    m2 = Marking.create
    m3 = Marking.create
    m4 = Marking.create
    key1 << m1
    key2 << m2
    key2 << m3
    key2 << m4

    kb2 = Keyboard.create
    key3 = Key.create
    key4 = Key.create
    kb2 << key3
    kb2 << key4
    m5 = Marking.create
    key3 << m5

    Courier::Courier.instance.contexts[:main].save
    kb1.keyboard_markings.count.should == 4
    kb2.keyboard_markings.count.should == 1
  end

  it "provides .create_in_new_context to create an object in a new context" do
    kb1 = Keyboard.create
    kb2 = Keyboard.create_in_new_context
    kb1.context.should != kb2.context
  end
end
