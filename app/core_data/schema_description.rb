module CoreData
  class SchemaDescription
    include Packager
    attr_accessor :model_descriptions, :version

    def initialize(schema)
      @model_descriptions = schema.entities.map do |e|
        CoreData::ModelDescription.new(e)
      end
    end

    def describe
      "\nSchema\n======\n" + \
        @model_descriptions.map{ |m_d| m_d.describe }.join("\n") + "\n"
    end
  end
end
