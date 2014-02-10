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
  end
end
