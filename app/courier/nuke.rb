# Courier::nuke.everything.right.now
#
# Intentionally wacky / overly verbose.
# There's no coming back from this;
# Same as reinstalling the app.

module Courier
  def self.nuke
    Nuke
  end

  class Nuke
    def self.everything
      Everything
    end
  end

  class Everything
    def self.right
      Right
    end
  end

  class Right
    def self.now
      file_manager = NSFileManager.defaultManager
      courier_documents_path = file_manager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).last.URLByAppendingPathComponent(StoreCoordinator::DIRECTORY).path
      file_paths = file_manager.contentsOfDirectoryAtPath(courier_documents_path, error:nil)
      unless file_paths.nil?
        file_paths.each do |path|
          file_manager.removeItemAtPath(courier_documents_path.stringByAppendingPathComponent(path), error:nil)
        end
      end
      true
    end
  end
end
