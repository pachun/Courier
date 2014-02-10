module CoreData
  class ModelDescription
    include Packager
    attr_accessor :name, :model, :properties, :relationships
    def initialize(model_definition)
      @name = model_definition.name
      @model = model_definition.managedObjectClassName
      save_properties(model_definition)
    end

    def save_properties(model_definition)
      @properties = []
      @relationships = []
      model_definition.properties.each do |p|
        if p.class == NSPropertyDescription || p.class == CoreData::PropertyDefinition
          @properties << CoreData::PropertyDescription.new(p)
        else
          @relationships << CoreData::RelationshipDescription.new(p)
        end
      end
    end

    def describe
      "  #{@name}\n" + \
        @relationships.map{ |r| r.describe }.join("") + \
        @properties.map{ |p| p.describe }.join("")
    end
  end
end
