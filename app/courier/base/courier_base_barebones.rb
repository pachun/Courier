module Courier
  class Base < CoreData::Model
    def self.conflict_policy(policy = :overwrite_local)
      @policy = policy
    end

    def self.properties
      @properties ||= []
    end

    def self.relationships
      @relationships ||= []
    end

    def self.keys
      @keys ||= []
    end

    def self.property(*property)
      check_for_key_in(property)
      properties << CoreData::PropertyDefinition.from(property)
    end

    def self.check_for_key_in(property)
      @keys ||= []
      if property[2].class == {}.class && property[2].has_key?(:key)
        @keys << property[0]
      end
    end

    def true_class
      dynamic_subclass = self.class.to_s
      peices = dynamic_subclass.split("_")
      if peices.count > 1
        peices[0].constantize
      else
        self.class
      end
    end
  end
end
