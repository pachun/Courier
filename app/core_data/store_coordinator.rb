class StoreCoordinator < NSPersistentStoreCoordinator
  def initialize(schema)
    initWithManagedObjectModel(schema)
  end

  alias_method :stores, :persistentStores
  alias_method :schema, :managedObjectModel

  def add_default_store
    error = Pointer.new(:object)
    addPersistentStoreWithType(NSSQLiteStoreType,
                               configuration: nil,
                               URL: default_store_url,
                               options: nil,
                               error: error)
    puts "Couldn't create store: #{error[0].userInfo}" unless error[0].nil?
  end

  private

  def default_store_url
    app_documents_path = NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).last
    app_documents_path.URLByAppendingPathComponent("default.sqlite")
  end
end
