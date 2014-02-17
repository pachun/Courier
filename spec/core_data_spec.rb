describe "The CoreData Module" do
  it "is defined" do
    defined?(CoreData).should == "constant"
  end

  it "aliases all NSAttributeTypes to CoreData::PropertyTypes" do
    defined?(CoreData::PropertyTypes).should == "constant"
    CoreData::PropertyTypes::Undefined.should == NSUndefinedAttributeType
    CoreData::PropertyTypes::Integer16.should == NSInteger16AttributeType
    CoreData::PropertyTypes::Integer32.should == NSInteger32AttributeType
    CoreData::PropertyTypes::Integer64.should == NSInteger64AttributeType
    CoreData::PropertyTypes::Decimal.should == NSDecimalAttributeType
    CoreData::PropertyTypes::Double.should == NSDoubleAttributeType
    CoreData::PropertyTypes::Float.should == NSFloatAttributeType
    CoreData::PropertyTypes::String.should == NSStringAttributeType
    CoreData::PropertyTypes::Boolean.should == NSBooleanAttributeType
    CoreData::PropertyTypes::Date.should == NSDateAttributeType
    CoreData::PropertyTypes::Data.should == NSBinaryDataAttributeType
    CoreData::PropertyTypes::Transformable.should == NSTransformableAttributeType
    CoreData::PropertyTypes::ID.should == NSObjectIDAttributeType
  end

  it "aliases all NSDeleteRule's to CoreData::DeleteRule" do
    defined?(CoreData::DeleteRule).should == "constant"
    CoreData::DeleteRule::Nothing.should == NSNoActionDeleteRule
    CoreData::DeleteRule::Nullify.should == NSNullifyDeleteRule
    CoreData::DeleteRule::Cascade.should == NSCascadeDeleteRule
    CoreData::DeleteRule::Deny.should == NSDenyDeleteRule
  end
end
