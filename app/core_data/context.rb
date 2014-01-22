module CoreData
  class Context < NSManagedObjectContext
    alias_method :store_coordinator=, :setPersistentStoreCoordinator
    alias_method :store_coordinator, :persistentStoreCoordinator

    def create(model_type)
      NSEntityDescription.insertNewObjectForEntityForName(model_type.to_s,
                                                          inManagedObjectContext:self)
    end
  end
end
