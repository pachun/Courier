module CoreData
  class PropertyDefinition < NSAttributeDescription
    # works in 'rake spec' but not 'rake'... no damn idea.
    # alias_method :type=, :setAttributeType
    def type=(type)
      setAttributeType(type)
    end
    alias_method :type, :attributeType
    alias_method :default_value=, :setDefaultValue
    alias_method :default_value, :defaultValue

    def same_as?(other_property)
      name == other_property.name && type == other_property.type
    end

    def self.from(property_array)
      self.new.tap do |p|
        p.name = property_array[0]
        p.type = ("CoreData::PropertyTypes::" + property_array[1].to_s).constantize
        if property_array[2].class == {}.class
          p.optional = false || (!property_array[2].has_key?(:required))
          p.default_value = nil || property_array[2][:default]
        end
      end
    end
  end
end
