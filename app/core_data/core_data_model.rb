module CoreData
  class Model < NSManagedObject
    def self.model_definition(context)
      entities = context.store_coordinator.schema.entities
      entities.select{ |e| e.model == self.to_s }.first
    end

    def self.all(context)
      error = Pointer.new(:object)
      query = NSFetchRequest.new
      query.entity = model_definition(context)
      found = context.executeFetchRequest(query, error:error)
      if error[0].nil?
        found
      else
        puts "Couldn't perform .all on #{self}"
        false
      end
    end
  end
end
