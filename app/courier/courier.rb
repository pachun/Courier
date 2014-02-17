module Courier
  class Courier
    def self.instance
      @@instance ||= new
    end

    def parcels=(parcels)
      @parcels = parcels
      build_schema
    end

    def build_schema
      @schema = CoreData::Schema.new
      @schema.entities = @parcels.map{ |p| p.to_coredata }
      @store_coordinator = CoreData::StoreCoordinator.new(@schema)
      @store_coordinator.add_store_named("courier")
      @contexts = {}
      @contexts[:main] = CoreData::Context.new
      @contexts[:main].store_coordinator = @store_coordinator
    end

    def contexts
      @contexts
    end
  end
end
