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
  end
end
