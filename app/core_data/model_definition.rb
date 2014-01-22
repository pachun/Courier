module CoreData
  class ModelDefinition < NSEntityDescription
    alias_method :model, :managedObjectClassName

    def model=(model)
      model = model.to_s # comes in as a class
      setManagedObjectClassName(model)
    end
  end
end
