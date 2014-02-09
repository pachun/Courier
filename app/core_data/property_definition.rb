module CoreData
  class PropertyDefinition < NSAttributeDescription
    # this works in 'rake spec' but not 'rake'... no idea.
    # alias_method :type=, :setAttributeType

    alias_method :type, :attributeType

    def type=(type)
      setAttributeType(type)
    end
  end
end
