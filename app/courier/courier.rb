module Courier
  SchemaSaveName = "courier.schema"
  CourierDatabaseName = "courier"

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
      if persisted_schema_exists?
        @persisted_schema = persisted_schema.to_schema
        if !@persisted_schema.same_as?(@schema)
          migrate
        end
      else
        persist_schema
      end
      sync_schema_with_store
    end

    def persist_schema
      CoreData::SchemaDescription.new(@schema).save(SchemaSaveName)
    end

    def sync_schema_with_store
      @store_coordinator = CoreData::StoreCoordinator.new(@schema)
      @store_coordinator.add_store_named(CourierDatabaseName)
      @contexts = {main: CoreData::Context.new}
      @contexts[:main].store_coordinator = @store_coordinator
    end

    def persisted_schema_exists?
      NSFileManager.defaultManager.fileExistsAtPath(Packager.URL(SchemaSaveName).path)
    end

    def persisted_schema
      CoreData::SchemaDescription.load(SchemaSaveName)
    end

    def migrate
      @migrator = Migrator.new
      puts "need to migrate"
    end

    ##
    ## Here down connects inverses
    ##
    def build_schema
      @schema = CoreData::Schema.new
      @schema.entities = @parcels.map{ |p| p.to_coredata }
      InverseRelationships.connect(@schema)
    end
  end
end
