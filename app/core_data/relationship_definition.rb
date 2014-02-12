module CoreData
  class RelationshipDefinition < NSRelationshipDescription
    alias_method :destination_model=, :setDestinationEntity
    alias_method :destination_model, :destinationEntity
    # alias_method :inverse_relationship=, :setInverseRelationship
    alias_method :inverse_relationship, :inverseRelationship
    alias_method :delete_rule=, :setDeleteRule
    alias_method :delete_rule, :deleteRule
    alias_method :max_count=, :setMaxCount
    alias_method :max_count, :maxCount
    alias_method :min_count=, :setMinCount
    alias_method :min_count, :minCount

    attr_accessor :inverse_id

    def inverse_relationship=(inverse_relationship)
      setInverseRelationship(inverse_relationship)
      random_id = self.class.random_inverse_id
      @inverse_id ||= random_id
      inverse_relationship.inverse_id ||= random_id
    end

    def self.random_inverse_id
      (0...32).map{ (65+rand(26)).chr }.join
    end
  end
end
