class StoreCoordinator < NSPersistentStoreCoordinator
  def initialize(schema)
    initWithManagedObjectModel(schema)
  end

  alias_method :stores, :persistentStores
  alias_method :schema, :managedObjectModel

  def add_store_named(name)
    error = Pointer.new(:object)
    addPersistentStoreWithType(NSSQLiteStoreType,
                               configuration: nil,
                               URL: db_path_for(name + ".sqlite"),
                               options: nil,
                               error: error)
    puts "Couldn't create store: #{error[0].userInfo}" unless error[0].nil?
  end

  private

  def db_path_for(filename)
    app_documents_path = NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).last
    app_documents_path.URLByAppendingPathComponent(filename)
  end
end
