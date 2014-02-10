describe "The Core Data Property Description Class" do
  before do
    @name = "name"
    @optional = false
    @type = CoreData::PropertyTypes::String
    @default_value = "Unknown Individual"

    name_property = CoreData::PropertyDefinition.new
    name_property.name = @name
    name_property.optional = @optional
    name_property.type = @type
    name_property.default_value = @default_value

    @name_property_description = CoreData::PropertyDescription.new(name_property)
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
end
