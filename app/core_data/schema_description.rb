module CoreData
  class SchemaDescription
    include Packager
    attr_accessor :model_descriptions, :version

    # NSCoder needs to be able to call initialize w/o any vars;
    # it reconstructs the attributes through initWithCoder, and
    # then calls initialize w/o any vars. *vars is for that
    # compatability.
    def initialize(*vars)
      schema = vars[0]
      if schema
        @model_descriptions = schema.entities.map do |e|
          CoreData::ModelDescription.new(e)
        end
      end
    end

    def to_schema
      definition = Schema.new.tap do |s|
        s.entities = @model_descriptions.map{ |m| m.to_definition }
      end
      hem_relationship_inverses(definition)
      definition
    end

    def describe
      "\nSchema\n======\n" + \
        @model_descriptions.map{ |m_d| m_d.describe }.join("\n") + "\n"
    end

    private
    def hem_relationship_inverses(schema_definition)
      rels = relationships_in(schema_definition)
      rels.each do |current|
        inverse_relationships = rels.select{ |r| r.inverse_id == current.inverse_id }
        inverse_relationships[0].inverse_relationship = inverse_relationships[1]
        inverse_relationships[1].inverse_relationship = inverse_relationships[0]
      end
    end

    # no support for regular NS relations b/c they don't have my custom inverse_id property.
    # Therefor, regular NS relationships can't be persisted thru courier & reconstituted.
    def relationships_in(schema)
      properties_in(schema).select do |p|
        p.class == CoreData::RelationshipDefinition# || p.class == NSRelationshipDescription
      end
    end

    def properties_in(schema)
      schema.entities.map{ |e| e.properties }.flatten!
    end
  end
end
