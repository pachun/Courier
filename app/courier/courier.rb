module Courier
  class Courier
    def self.instance
      @@instance ||= new
    end

    def parcels=(parcels)
      @parcels = parcels
      build_all
    end

    def contexts
      @contexts
    end

    private

    def build_all
      build_schema
      build_store
      setup_default_context
    end

    def build_store
      @store_coordinator = CoreData::StoreCoordinator.new(@schema)
      @store_coordinator.add_store_named("courier")
    end

    def setup_default_context
      @contexts = {}
      @contexts[:main] = CoreData::Context.new
      @contexts[:main].store_coordinator = @store_coordinator
    end

    # here and downward builds the schema and sets up relationship inverses
    def build_schema
      @schema = CoreData::Schema.new
      @schema.entities = @parcels.map{ |p| p.to_coredata }
      hem_relationship_inverses
    end

    def hem_relationship_inverses
      relationships = properties.select{ |p| p.class == CoreData::RelationshipDefinition }
      relationships.each do |relationship|
        find_inverse_for(relationship, in:relationships) if relationship.inverse_id.nil?
      end
    end

    def properties
      @schema.entities.map{ |e| e.properties }.flatten
    end

    def find_inverse_for(r, in:relationships)
      inverse_relation = relationships.select do |i|
        i.destination_model == r.local_model && i.local_model == r.destination_model
      end.first
      set_inverses(r, inverse_relation)
    end

    def set_inverses(r1, r2)
      r1.inverse_relationship = r2
      r2.inverse_relationship = r1
      finalize(r1, and:r2)
    end

    # kept the destination_model as a String until now, because when two models declare
    # each other as inverses, one is inevitably undefined on the first inverse
    # definition, resulting in an uninitialize constant error. At this point, both
    # models and inverse relationships have been defined, so we can constantize now.
    def finalize(r1, and:r2)
      r1.destination_model = r1.destination_model.constantize
      r2.destination_model = r2.destination_model.constantize
    end
  end
end
