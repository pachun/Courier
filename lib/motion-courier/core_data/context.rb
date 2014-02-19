module CoreData
  class Context < NSManagedObjectContext
    alias_method :store_coordinator=, :setPersistentStoreCoordinator
    alias_method :store_coordinator, :persistentStoreCoordinator

    def create(model_type)
      NSEntityDescription.insertNewObjectForEntityForName(model_type.to_s,
                                                          inManagedObjectContext:self)
    end

    def save
      error = Pointer.new(:object)
      if hasChanges && !super(error)
        puts "couldn't save context: #{error[0].localizedDescription}"
        false
      else
        true
      end
    end
  end
end
