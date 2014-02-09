module Packager
  module ClassMethods
    def attr_accessor(*vars)
      @packager_attributes ||= Array.new.tap{ |a| a.concat(vars) }
      super
    end

    def packager_attributes
      @packager_attributes
    end

    def load(handle)
      data = NSData.dataWithContentsOfFile(Packager.URL(handle), options:NSDataReadingMappedIfSafe, error:nil)
      NSKeyedUnarchiver.unarchiveObjectWithData(data).tap do |record|
        record.packager_handle = handle
      end
    end
  end

  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  def self.URL(handle)
    app_documents_path = NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).last
    app_documents_path.URLByAppendingPathComponent(handle)
  end

  def initialize(*vars)
    set_random_handle
    super
  end

  def packager_attributes
    self.class.packager_attributes
  end

  def set_random_handle
    @packager_handle = (0...32).map{ (65+rand(26)).chr }.join + "_#{self.class.to_s}.data"
  end

  def encodeWithCoder(encoder)
    packager_attributes.each do |attribute|
      encoder.encodeObject(self.send(attribute), forKey:attribute.to_s)
    end
  end

  def initWithCoder(decoder)
    packager_attributes.each do |attribute|
      setter = (attribute.to_s + "=:").to_sym
      value = decoder.decodeObjectForKey(attribute.to_s)
      self.send(setter, value)
    end
    init
  end

  def packager_url
    Packager.URL(@packager_handle)
  end

  def save(custom_handle = @packager_handle)
    @packager_handle = custom_handle
    data = NSKeyedArchiver.archivedDataWithRootObject(self)
    error = Pointer.new(:object)
    written = data.writeToURL(packager_url, options:NSDataWritingAtomic, error:error)
    if written && error[0].nil?
      @packager_handle
    else
      puts "Couldn't Save #{self.class.to_s} Because #{error[0].localizedDescription}"
      false
    end
  end

  def packager_handle=(handle)
    @packager_handle = handle
  end
end
