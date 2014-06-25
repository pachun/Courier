module CoreData
  class StoreCoordinator < NSPersistentStoreCoordinator
    def initialize(schema)
      initWithManagedObjectModel(schema)
    end

    alias_method :stores, :persistentStores
    alias_method :schema, :managedObjectModel

    def add_store_at(location)
      error = Pointer.new(:object)
      addPersistentStoreWithType(NSSQLiteStoreType,
                                configuration: nil,
                                URL: location,
                                options: nil,
                                error: error)
      puts "Couldn't create store: #{error[0].userInfo}" unless error[0].nil?
    end
  end
end
