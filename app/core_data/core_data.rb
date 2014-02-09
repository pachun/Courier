module CoreData
  module PropertyTypes
    Undefined = NSUndefinedAttributeType
    Integer16 = NSInteger16AttributeType
    Integer32 = NSInteger32AttributeType
    Integer64 = NSInteger64AttributeType
    Decimal = NSDecimalAttributeType
    Double = NSDoubleAttributeType
    Float = NSFloatAttributeType
    String = NSStringAttributeType
    Boolean = NSBooleanAttributeType
    Date = NSDateAttributeType
    Data = NSBinaryDataAttributeType
    Transformable = NSTransformableAttributeType
    ID = NSObjectIDAttributeType
  end

  module DeleteRule
    DoNothing = NSNoActionDeleteRule
    Nullify = NSNullifyDeleteRule
    Cascade = NSCascadeDeleteRule
    Deny = NSDenyDeleteRule
  end
end
