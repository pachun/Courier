class Courier::StoreCoordinator < CoreData::StoreCoordinator
  DIRECTORY = "/courier"
  STORE_NAME = "courier.sqlite"

  def build
    app_documents_url = NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).last
    courier_directory_url = app_documents_url.URLByAppendingPathComponent(DIRECTORY)
    db_url = courier_directory_url.URLByAppendingPathComponent(STORE_NAME)

    unless NSFileManager.defaultManager.fileExistsAtPath(courier_directory_url.path)
      NSFileManager.defaultManager.createDirectoryAtPath(courier_directory_url.path, withIntermediateDirectories:false, attributes:nil, error:nil)
    end
    add_store_at(db_url)
  end
end
