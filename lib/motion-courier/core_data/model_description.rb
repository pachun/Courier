module CoreData
  class ModelDescription
    include Packager
    attr_accessor :name, :model, :properties, :relationships

    # NSCoder needs to be able to call initialize w/o any vars;
    # it reconstructs the attributes through initWithCoder, and
    # then calls initialize w/o any vars. *vars is for that
    # compatability.
    def initialize(*vars)
      model_definition = vars[0]
      if model_definition
        @name = model_definition.name
        @model = model_definition.managedObjectClassName
        save_properties(model_definition)
      end
    end

    def to_definition
      ModelDefinition.new.tap do |d|
        d.name = @name
        d.model = @model
        properties = @relationships.map{ |r| r.to_definition } + \
          @properties.map{ |p| p.to_definition }
        d.properties = properties
      end
    end

    def describe
      "  #{@name}\n" + \
        @relationships.map{ |r| r.describe }.join("") + \
        @properties.map{ |p| p.describe }.join("")
    end

    private
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
  end
end
