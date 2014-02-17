module CoreData
  class Schema < NSManagedObjectModel
    def same_as?(other_schema)
      return false if entities.count != other_schema.entities.count
      entities.each do |e|
        potential_match = other_schema.entities.select{ |o| o.name == e.name }.first
        if potential_match.nil?
          return false
        else
          return false unless e.same_as?(potential_match)
        end
      end
      true
    end
  end
end
