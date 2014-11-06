module Courier
  class Base < CoreData::Model
    attr_accessor :merge_relationships

    def self.to_coredata
      @coredata_definition ||= CoreData::ModelDefinition.new.tap do |m|
        m.name = self.to_s
        m.model = self
        m.properties = relationships + properties
      end
    end

    def self.create
      Courier.instance.contexts[:main].create(self.to_s)
    end

    def self.create_in_new_context
      Courier.instance.new_context.create(self.to_s).tap do |i|
        i.merge_relationships = []
      end
    end

    def save
      Courier.instance.save
    end

    def delete
      context.deleteObject(self)
    end

    def delete!
      delete
      Courier.instance.contexts.delete_if do |key, value|
        value == context
      end
    end

    def merge!
      (main_context_match || true_class.create).tap do |main_context_copy|
        save_properties(main_context_copy)
        apply_main_context_relationships(main_context_copy)
        save

        delete!
      end
    end

    def merge_if(&block)
      if block.call
        merge!
      else
        false
      end
    end

    def main_context_match
      search_scopes = main_context_match_search_scopes
      if search_scopes.count == 0
        nil
      elsif search_scopes.count == 1
        true_class.where(search_scopes[0]).first
      else
        true_class.where(Scope.and(search_scopes)).first
      end
    end

    private

    def save_properties(counterpart)
      true_class.properties.each do |p|
        counterpart.send("#{p.name}=", send("#{p.name}"))
      end
    end

    def apply_main_context_relationships(counterpart)
      merge_relationships.each do |r|
        counterpart.send(r[:relation], r[:relative])
      end
    end

    def main_context_match_search_scopes
      primary_keys = true_class.keys
      [].tap do |search_scopes|
        primary_keys.each do |key|
          local_key_value = send("#{key}")
          unless local_key_value.nil?
            search_scopes << Scope.where(key.to_sym, is: local_key_value)
          end
        end
      end
    end
  end
end
