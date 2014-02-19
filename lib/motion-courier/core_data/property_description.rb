module CoreData
  class PropertyDescription
    include Packager
    attr_accessor :name, :optional, :type, :default_value

    # NSCoder needs to be able to call initialize w/o any vars;
    # it reconstructs the attributes through initWithCoder, and
    # then calls initialize w/o any vars. *vars is for that
    # compatability.
    def initialize(*vars)
      property_definition = vars[0]
      if property_definition
        @name = property_definition.name
        @optional = property_definition.optional?
        @type = property_definition.attributeType
        @default_value = property_definition.defaultValue
      end
    end

    def to_definition
      PropertyDefinition.new.tap do |d|
        d.name = @name
        d.type = @type
        d.optional = @optional
        d.default_value = @default_value
      end
    end

    def describe
      optional_string = self.class.optional_string(@optional)
      type_string = self.class.type_string(@type)
      if @default_value
        default_string = "defaults to #{@default_value}"
      else
        default_string = "no default"
      end
      "    #{@name} (#{type_string}, #{optional_string}, #{default_string})\n"
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
        "string"
      elsif type == PropertyTypes::Integer16
        "small integer"
      elsif type == PropertyTypes::Integer32
        "integer"
      elsif type == PropertyTypes::Integer64
        "large integer"
      elsif type == PropertyTypes::Boolean
        "bool"
      elsif type == PropertyTypes::Date
        "date"
      elsif type == PropertyTypes::Data
        "data"
      end
    end
  end
end
