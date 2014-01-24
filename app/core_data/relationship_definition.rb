module CoreData
  class RelationshipDefinition < NSRelationshipDescription
    alias_method :destination_model=, :setDestinationEntity
    alias_method :destination_model, :destinationEntity
    alias_method :inverse_relationship=, :setInverseRelationship
    alias_method :inverse_relationship, :inverseRelationship
  end
end
