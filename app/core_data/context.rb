module CoreData
  class Context < NSManagedObjectContext
    alias_method :store_coordinator=, :setPersistentStoreCoordinator
    alias_method :store_coordinator, :persistentStoreCoordinator
  end
end
