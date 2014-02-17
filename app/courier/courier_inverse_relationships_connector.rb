module Courier
  module InverseRelationships
    def self.connect(schema)
      properties = schema.entities.map{ |e| e.properties }.flatten
      relationships = properties.select{ |p| p.class == CoreData::RelationshipDefinition }
      relationships.each do |relationship|
        find_inverse_for(relationship, in:relationships) if relationship.inverse_id.nil?
      end
    end

    def self.find_inverse_for(r, in:relationships)
      inverse_relation = relationships.select do |i|
        i.destination_model == r.local_model && i.local_model == r.destination_model
      end.first
      set_inverses(r, inverse_relation)
    end

    def self.set_inverses(r1, r2)
      r1.inverse_relationship = r2
      r2.inverse_relationship = r1
      finalize(r1, and:r2)
    end

    # kept the destination_model as a String until now, because when two models declare
    # each other as inverses, one of the models is necessarily undefined on the first inverse
    # definition, resulting in an uninitialize constant error.
    #
    # At /current/ point though, both models and inverse relationships have been defined,
    # so we can constantize now.
    def self.finalize(r1, and:r2)
      r1.destination_model = r1.destination_model.constantize.to_coredata
      r2.destination_model = r2.destination_model.constantize.to_coredata
    end
  end
end
