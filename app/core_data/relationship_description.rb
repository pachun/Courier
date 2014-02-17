module CoreData
  class RelationshipDescription
    include Packager
    attr_accessor :name, :destination_model, :delete_rule, :max_count, :min_count, :inverse_id

    # NSCoder needs to be able to call initialize w/o any vars;
    # it reconstructs the attributes through initWithCoder, and
    # then calls initialize w/o any vars. *vars is for that
    # compatability.
    def initialize(*vars)
      relationship_definition = vars[0]
      if relationship_definition
        @name = relationship_definition.name
        @destination_model = relationship_definition.destinationEntity.name.to_s
        @delete_rule = relationship_definition.deleteRule
        @max_count = relationship_definition.maxCount
        @min_count = relationship_definition.minCount
        @inverse_id = relationship_definition.inverse_id
      end
    end

    def to_definition
      RelationshipDefinition.new.tap do |d|
        d.name = @name
        d.destination_model = @destination_model
        d.delete_rule = @delete_rule
        d.max_count = @max_count
        d.min_count = @min_count
        d.inverse_id = @inverse_id
      end
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
      if delete_rule == DeleteRule::Nothing
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
