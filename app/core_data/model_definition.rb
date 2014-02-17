module CoreData
  class ModelDefinition < NSEntityDescription
    alias_method :model, :managedObjectClassName

    def model=(model)
      model = model.to_s # comes in as a class
      setManagedObjectClassName(model)
    end

    def same_as?(other_model)
      name == other_model.name &&
        model == other_model.model &&
        same_properties_as?(other_model)
    end

    private
    def same_properties_as?(other_model)
      return false if properties.count != other_model.properties.count
      properties.each do |p|
        potential_match = other_model.properties.select{ |o| o.name == p.name }.first
        if potential_match.nil?
          return false
        else
          return false unless p.same_as?(potential_match)
        end
      end
      true
    end
  end
end
