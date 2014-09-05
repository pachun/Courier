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

    attr_accessor :local_model, :inverse_id

    def inverse_relationship=(inverse_relationship)
      setInverseRelationship(inverse_relationship)
      random_id = self.class.random_inverse_id
      @inverse_id ||= random_id
      inverse_relationship.inverse_id ||= random_id
    end

    def self.random_inverse_id
      (0...32).map{ (65+rand(26)).chr }.join
    end

    def same_as?(other_relationship)
      name == other_relationship.name &&
        destination_model == other_relationship.destination_model &&
        delete_rule == other_relationship.delete_rule
        min_count == other_relationship.min_count &&
        max_count == other_relationship.max_count
    end

    def self.from(type, local_class, related_class, relation_name, deletion_rule)
      self.new.tap do |r|
        r.name = relation_name.to_s
        r.local_model = local_class
        r.destination_model = related_class
        r.min_count = type[:min]
        r.max_count = type[:max]
        r.delete_rule = DeleteRule::from_symbol(deletion_rule)
      end
    end
  end
end
