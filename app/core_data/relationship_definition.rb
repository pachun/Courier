module CoreData
  class RelationshipDefinition < NSRelationshipDescription
    alias_method :destination_model=, :setDestinationEntity
    alias_method :destination_model, :destinationEntity
    alias_method :inverse_relationship=, :setInverseRelationship
    alias_method :inverse_relationship, :inverseRelationship
    alias_method :delete_rule=, :setDeleteRule
    alias_method :delete_rule, :deleteRule
    alias_method :max_count=, :setMaxCount
    alias_method :max_count, :maxCount
    alias_method :min_count=, :setMinCount
    alias_method :min_count, :minCount
  end
end
