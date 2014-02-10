module CoreData
  class RelationshipDescription
    include Packager
    attr_accessor :name, :destination_model, :delete_rule, :max_count, :min_count

    def initialize(relationship_definition)
      @name = relationship_definition.name
      @destination_model = relationship_definition.destinationEntity.name.to_s
      @delete_rule = relationship_definition.deleteRule
      @max_count = relationship_definition.maxCount
      @min_count = relationship_definition.minCount
    end

    def describe
      relationship_type = self.class.type_string(@min_count, @max_count)
      delete_rule = self.class.delete_string(@delete_rule)
      "    #{@destination_model} (#{relationship_type}) => #{delete_rule}\n"
    end

    def self.type_string(min, max)
      if min == 0 && max == 0
        "has many"
      elsif min == 0 && max == 1
        "belongs to"
      end
    end

    def self.delete_string(delete_rule)
      if delete_rule == DeleteRule::DoNothing
        "do nothing on delete"
      elsif delete_rule == DeleteRule::Nullify
        "nullify on delete"
      elsif delete_rule == DeleteRule::Cascade
        "cascade delete"
      elsif delete_rule == DeleteRule::Deny
        "don't allow deletes"
      end
    end
  end
end
