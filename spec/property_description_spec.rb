describe "The Core Data Property Description Class" do
  before do
    @name = "name"
    @optional = false
    @type = CoreData::PropertyTypes::String
    @default_value = "Unknown Individual"

    @name_property = CoreData::PropertyDefinition.new
    @name_property.name = @name
    @name_property.optional = @optional
    @name_property.type = @type
    @name_property.default_value = @default_value

    @name_property_description = CoreData::PropertyDescription.new(@name_property)
  end

  it "persists name, optionality, type, and behavioral class" do
    @name_property_description.name.should == @name
    @name_property_description.optional.should == @optional
    @name_property_description.type.should == @type
    @name_property_description.default_value.should == @default_value
  end

  it "describes itself properly" do
    optional_string = CoreData::PropertyDescription.optional_string(@optional)
    type_string = CoreData::PropertyDescription.type_string(@type)
    if @default_value
      default_string = "defaults to #{@default_value}"
    else
      default_string = "no default"
    end
    @name_property_description.describe.should == \
      "    #{@name} => #{type_string}, #{optional_string}, #{default_string}\n"
  end

  it "can save and reconstruct itself through NSCoder via Packager" do
    handle = @name_property_description.save
    rebuilt = CoreData::PropertyDescription.load(handle)
    rebuilt.name.should == @name
    rebuilt.optional.should == @optional
    rebuilt.type.should == @type
    rebuilt.default_value.should == @default_value
  end

  it "has .to_definition to get back the CoreData::PropertyDefinition" do
    definition = @name_property_description.to_definition
    definition.class.should == @name_property.class
    definition.name.should == @name_property.name
    definition.optional?.should == @name_property.optional?
    definition.default_value.should == @name_property.default_value
  end
end
