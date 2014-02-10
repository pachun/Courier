module CoreData
  class PropertyDescription
    include Packager
    attr_accessor :name, :optional, :type, :default_value

    def initialize(property_definition)
      @name = property_definition.name
      @optional = property_definition.optional?
      @type = property_definition.attributeType
      @default_value = property_definition.defaultValue
    end

    def describe
      optional_string = self.class.optional_string(@optional)
      type_string = self.class.type_string(@type)
      if @default_value
        default_string = "defaults to #{@default_value}"
      else
        default_string = "no default"
      end
      "    #{@name} => #{type_string}, #{optional_string}, #{default_string}\n"
    end

    def self.optional_string(optional)
      if optional == false
        "not optional"
      else
        "optional"
      end
    end

    def self.type_string(type)
      if type == PropertyTypes::String
        "String"
      elsif type == PropertyTypes::Integer16
        "Integer16"
      elsif type == PropertyTypes::Integer32
        "Integer32"
      elsif type == PropertyTypes::Integer64
        "Integer64"
      elsif type == PropertyTypes::Boolean
        "Boolean"
      elsif type == PropertyTypes::Date
        "Date"
      elsif type == PropertyTypes::Data
        "Data"
      end
    end
  end
end
