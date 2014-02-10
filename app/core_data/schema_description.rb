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
      Schema.new.tap do |s|
        s.entities = @model_descriptions.map{ |m| m.to_definition }
      end
    end

    def describe
      "\nSchema\n======\n" + \
        @model_descriptions.map{ |m_d| m_d.describe }.join("\n") + "\n"
    end
  end
end
