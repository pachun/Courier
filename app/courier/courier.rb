module Courier
  SchemaSaveName = "courier.schema"
  CourierDatabaseName = "courier"
  MigrationLogSaveName = "migrations.log"

  def self.save
    Courier.instance.save
  end

  class Courier
    attr_reader :migrator
    attr_accessor :url

    def url=(url)
      @url = url
    end

    def self.instance
      @@instance ||= new
    end

    def parcels=(parcels)
      @parcels = parcels.concat([::Cache____])
      build_all
    end

    def contexts
      @contexts
    end

    def new_context
      context_name = "context_" + (0...32).map{ (65+rand(26)).chr }.join
      @contexts[context_name] = CoreData::Context.new.tap do |context|
        context.store_coordinator = @store_coordinator
      end
    end

    def save
      @contexts[:main].save
    end

    def build_all
      build_schema
      sync_schema_with_store
    end

    def build_schema
      @schema = CoreData::Schema.new
      @schema.entities = @parcels.map{ |p| p.to_coredata }
      InverseRelationships.connect(@schema)
    end

    def sync_schema_with_store
      @store_coordinator = StoreCoordinator.new(@schema)
      @store_coordinator.build
      @contexts = {main: CoreData::Context.new}
      @contexts[:main].store_coordinator = @store_coordinator
    end

    # def migrate(msg = "")
    #   if @migrator.migrate_from(@persisted_schema, to:@schema)
    #     @schema.version = @persisted_schema.version + 1
    #     persist_schema
    #     log_schema(msg)
    #   end
    #   sync_schema_with_store
    # end

    # def last_schema
    #   puts @migrator.logs.last[:description]
    # end
    #
    # def new_schema
    #   puts CoreData::SchemaDescription.new(@schema).describe
    # end

    private

    # def build_all
    #   build_schema
    #   # if persisted_schema_exists?
    #   #   return if resolve_schema_differences == :asking_to_migrate
    #   # else
    #   #   persist_built_schema
    #   # end
    #   sync_schema_with_store
    # end

    # def persist_built_schema
    #   @schema.version = 1
    #   persist_schema
    #   log_schema("First generated schema.")
    # end

    # def resolve_schema_differences
    #   @migrator = Migrator.load(MigrationLogSaveName)
    #   @persisted_schema = persisted_schema.to_schema
    #   if @persisted_schema.same_as?(@schema)
    #     @schema.version = @persisted_schema.version
    #   else
    #     @migrator.ask_to_migrate_from(@persisted_schema, to:@schema)
    #     :asking_to_migrate
    #   end
    # end

    # def log_schema(message)
    #   @migrator ||= Migrator.new
    #   @migrator.log(@schema, message)
    #   @migrator.save(MigrationLogSaveName)
    # end

    # def persist_schema
    #   delete_persisted_schema if persisted_schema_exists?
    #   schema_description = CoreData::SchemaDescription.new(@schema)
    #   schema_description.save(SchemaSaveName)
    # end

    # def sync_schema_with_store
    #   @store_coordinator = CoreData::StoreCoordinator.new(@schema)
    #   @store_coordinator.add_store_named(CourierDatabaseName + @schema.version.to_s) #courier1, courier2, etc (.sqlite is appended by store_coordinator)
    #   @contexts = {main: CoreData::Context.new}
    #   @contexts[:main].store_coordinator = @store_coordinator
    # end

    # def persisted_schema_exists?
    #   NSFileManager.defaultManager.fileExistsAtPath(Packager.URL(SchemaSaveName).path)
    # end
    #
    # def persisted_schema
    #   CoreData::SchemaDescription.load(SchemaSaveName)
    # end
    #
    # def delete_persisted_schema
    #   NSFileManager.defaultManager.removeItemAtPath(Packager.URL(SchemaSaveName).path, error:nil)
    # end
  end
end
