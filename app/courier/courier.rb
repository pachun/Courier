module Courier
  SchemaSaveName = "courier.schema"
  CourierDatabaseName = "courier"
  MigrationLogSaveName = "migrations.log"

  class Courier
    attr_accessor :migrator

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
        @migrator = Migrator.load(MigrationLogSaveName)
        @persisted_schema = persisted_schema.to_schema
        if @persisted_schema.same_as?(@schema)
          @schema.version = @persisted_schema.version
        else
          migrate
        end
      else
        @schema.version = 1
        persist_schema
        log_schema("First generated schema.")
      end
      sync_schema_with_store
    end

    def log_schema(message)
      @migrator ||= Migrator.new
      @migrator.log(@schema, message)
      @migrator.save(MigrationLogSaveName)
    end

    def persist_schema
      schema_description = CoreData::SchemaDescription.new(@schema)
      schema_description.save(SchemaSaveName)
    end

    def sync_schema_with_store
      @store_coordinator = CoreData::StoreCoordinator.new(@schema)
      @store_coordinator.add_store_named(CourierDatabaseName + @schema.version.to_s) #courier1, courier2, etc (.sqlite is appended by store_coordinator)
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

    def build_schema
      @schema = CoreData::Schema.new
      @schema.entities = @parcels.map{ |p| p.to_coredata }
      InverseRelationships.connect(@schema)
    end
  end
end
