module Courier
  class Migrator
    include Packager
    attr_accessor :logs

    def log(schema, message)
      @logs ||= []
      @logs << {
        version: schema.version,
        message: message,
        description: CoreData::SchemaDescription.new(schema).describe,
      }
    end

    def ask_to_migrate_from(old_schema, to:new_schema)
      error = Pointer.new(:object)
      mapping_model = NSMappingModel.inferredMappingModelForSourceModel(old_schema, destinationModel:new_schema, error:error)
      if mapping_model.nil?
        puts %Q(\nYour schema has changed too significantly for a lightweight migration to be possible.\n\nContinuing application without courier core data support.\nTo see the last schema, call Courier::Courier.instance.last_schema\n\n)
      else
        puts %Q(\nYour schema has changed.\n\nTo migrate, call Courier::Courier.instance.migrate\nTo see the last schema, call Courier::Courier.instance.last_schema\nTo see the new schema, call Courier::Courier.instance.new_schema\n\n)
      end
    end

    def migrate_from(old_schema, to:new_schema)
      error = Pointer.new(:object)
      mapping_model = NSMappingModel.inferredMappingModelForSourceModel(old_schema, destinationModel:new_schema, error:error)
      if mapping_model.nil?
        puts "Cannot perform lightweight migration (https://developer.apple.com/library/ios/documentation/cocoa/conceptual/CoreDataVersioning/Articles/vmLightweightMigration.html)"
      end
      old_db_location = Packager.URL(CourierDatabaseName + old_schema.version.to_s + ".sqlite")
      new_db_location = Packager.URL(CourierDatabaseName + (old_schema.version + 1).to_s + ".sqlite")
      migration_manager = NSMigrationManager.alloc.initWithSourceModel(old_schema, destinationModel:new_schema)
      migration_manager.migrateStoreFromURL(old_db_location,
                                            type:NSSQLiteStoreType,
                                            options:nil,
                                            withMappingModel:mapping_model,
                                            toDestinationURL:new_db_location,
                                            destinationType:NSSQLiteStoreType,
                                            destinationOptions:nil,
                                            error:error) # returns true / false (so keep last here)
    end
  end
end
