module CoreData
  class EntityDefinition < NSEntityDescription
    alias_method :model, :managedObjectClassName

    def model=(model)
      setManagedObjectClassName(model.to_s)
    end
  end
end
