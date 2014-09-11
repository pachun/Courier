module Courier
  class Base < CoreData::Model
    def self.all_in_context(context)
      super(context)
    end

    def self.all
      all_in_context(Courier.instance.contexts[:main])
    end

    def self.where(scope)
      fetch = NSFetchRequest.fetchRequestWithEntityName(self.to_s)
      fetch.setPredicate(scope)
      error = Pointer.new(:object)

      results = Courier.instance.contexts[:main].executeFetchRequest(fetch, error:error)
      puts "Error searching for #{scope.predicateFormat}: #{error[0]}" unless error[0].nil?
      results
    end

    def self.scopes
      @scopes ||= []
    end

    def self.scope(name, scope)
      if scope.class == {}.class || scope.class == String
        scope = Scope.from_structure(scope)
      end
      scopes << {name:name, scope:scope}
      class_constant = self
      define_singleton_method("#{name}"){ class_constant.where(scope); }
    end
  end
end
