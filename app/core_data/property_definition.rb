module CoreData
  class PropertyDefinition < NSAttributeDescription
    alias_method :type=, :setAttributeType
    alias_method :type, :attributeType
  end
end
