module Courier
  class Base < CoreData::Model
    def self.to_coredata
      @coredata_definition ||= CoreData::ModelDefinition.new.tap do |m|
        m.name = self.to_s
        m.model = self
        m.properties = relationships + properties
      end
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
      properties << coredata_property_from(property)
    end

    def self.check_for_key_in(property)
      @keys ||= []
      if property[2] && property[2][:key]
        @keys << property[0]
      end
    end

    # Setting the owner_class and owned_classes as a String for now,
    # to be constantized! later. Can't do it here, because one class
    # is always defined at this point, and the other is not yet.
    #
    # "constantization" and hemming of inverse relationships will
    # happen just before a store_coordinator is generated from the
    # schema (in courier.rb)
    def self.belongs_to(owner_class, as:name, on_delete:delete_action)
      belongs_to = {min:0, max:1}
      owner_class = owner_class.to_s.capitalize
      relationships << coredata_relationship_from(belongs_to, owner_class, name, delete_action)
    end

    # this doesnt add an actial relationship; just dynamically
    # defines a method to traverse the has_many:through: relationship
    # breadcrumbs on the intermediary and destination classes
    def self.has_many(name, through:relationship_breadcrumbs)
      middling_relationship = relationship_breadcrumbs.first
      destination_relationship = relationship_breadcrumbs.last
      define_method("#{name}") do
        middling_objects = self.send("#{middling_relationship}")
        middling_objects.map{ |c| c.send("#{destination_relationship}") }.flatten
      end
    end

    def self.has_many(owned_class, as:name, on_delete:delete_action)

      # if a keyboard has many keys, this provides keyboard.keys to return an array
      # of all the keys
      define_method("#{name}") do
        frozen_array = self.send("#{name}__").allObjects
        frozen_array.map{ |f| f }
      end

      # in the same context, this provides an alternative to setting a relationship from
      # the owned side; eg we can do
      #
      # keyboard << key
      #
      # instead of
      #
      # key.keyboard = keyboard
      #
      define_method("<<") do |x|
        owner_instance = self
        x.send("#{owner_instance.true_class.to_s.downcase}=", owner_instance)
      end

      has_many = {min:0, max:0}
      owned_class = owned_class.to_s.singularize.capitalize
      relationships << coredata_relationship_from(has_many, owned_class, "#{name}__", delete_action)
    end

    def self.coredata_relationship_from(type, related_class, name, delete_action)
      CoreData::RelationshipDefinition.new.tap do |r|
        r.name = name.to_s
        r.local_model = self.to_s
        r.destination_model = related_class
        r.min_count = type[:min]
        r.max_count = type[:max]
        r.delete_rule = CoreData::DeleteRule::from_symbol(delete_action)
      end
    end

    def self.coredata_property_from(property)
      CoreData::PropertyDefinition.new.tap do |p|
        p.name = property[0]
        p.type = ("CoreData::PropertyTypes::" + property[1].to_s).constantize
        if property[2]
          p.optional = false || (!property[2][:required])
          p.default_value = nil || property[2][:default]
        end
      end
    end

    def self.create
      Courier.instance.contexts[:main].create(self.to_s)
    end

    def self.create_in_new_context
      Courier.instance.new_context.create(self.to_s)
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

    #
    # Scoping helpers (also there is an nsarray hack in another file)
    #

    def self.all_in_context(context)
      super(context)
    end

    def self.all
      all_in_context(Courier.instance.contexts[:main])
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

    #
    # reading json resources...
    #

    @@individual_path = ""
    @@collection_path = ""
    @@json_to_local = ""
    def self.individual_path=(path)
      @@individual_path = path
    end

    def self.collection_path=(path)
      @@collection_path = path
    end

    def self.json_to_local=(mapping)
      @@json_to_local = mapping
    end

    def self.individual_path
      @@individual_path
    end

    def self.collection_path
      @@collection_path
    end

    def self.json_to_local
      @@json_to_local
    end

    # group resource fetch

    def self.fetch(&block)
      AFMotion::HTTP.get(collection_url) do |result|
        if result.success?
          _compare_local_collection_to_fetched_collection(results.body, &block)
        else
          puts "error while fetched collection of #{self.to_s.pluralize}: #{results.error.localizedDescription}"
        end
      end
    end

    def self._compare_local_collection_to_fetched_collection(json, &block)
      block.call( curate_conflicts(json) )
    end

    def self.curate_conflicts(json)
      conflicts = json.map do |foreign_resource_json|
        foreign_resource = create_in_new_context
        save_json(foreign_resource_json, to: foreign_resource)
        local_resource = foreign_resource.main_context_match
        {local: local_resource, foreign: foreign_resource}
      end
    end

    # single resource "soft" fetch

    def fetch(&block)
      AFMotion::HTTP.get(individual_url) do |result|
        if result.success?
          _save_single_resource_in_new_context(result.object, &block)
        else
          puts "error while fetching #{self.class.to_s.downcase} resource: #{result.error.localizedDescription}"
        end
      end
    end

    def _save_single_resource_in_new_context(json, &block)
      fetched_resource = true_class.create_in_new_context
      true_class.save_json(json, to:fetched_resource)
      block.call(fetched_resource)
    end

    def main_context_match
      primary_keys = true_class.keys
      search_scopes = []
      primary_keys.each do |key|
        local_key_value = send("#{key}")
        unless local_key_value.nil?
          search_scopes << Scope.where(key.to_sym, is: local_key_value)
        end
      end

      if search_scopes.count == 0
        nil
      elsif search_scopes.count == 1
        true_class.where(search_scopes[0]).first
      else
        true_class.where(Scope.and(search_scopes)).first
      end
    end

    # single resource "hard" fetch

    def fetch!(&block)
      fetch do |foreign_resource|
        foreign_resource.merge!
        block.call
      end
    end

    # single resource merge (for merging into main context)

    def merge!
      counterpart = main_context_match
      if counterpart != nil
        true_class.properties.each do |p|
          counterpart.send("#{p.name}=", send("#{p.name}"))
        end
        delete!
        true
      else
        false
      end
    end

    def merge_if(&block)
      if block.call
        merge!
      else
        false
      end
    end

    # single resource post

    def push(&block)
      AFMotion::JSON.post(individual_url, post_parameters) do |result|
        block.call(result)
      end
    end

    # helpful methods for foreign resource syncing

    def self.save_json(json, to:instance)
      json_to_local.keys.each do |json_key|
        if json.has_key?(json_key.to_s)
          local_key = json_to_local[json_key]
          instance.send("#{local_key}=", json[json_key.to_s])
        end
      end
    end

    def individual_url
      handle =
        true_class.individual_path.split("/").map do |peice|
          if peice[0] == ":"
            self.send(peice[1..-1].to_sym)
          else
            peice
          end
        end.join("/")
        [Courier.instance.url, handle].join("/")
    end

    def self.collection_url
      [Courier.instance.url, collection_path].join("/")
    end

    # self.json_to_local = {id: :id, userId: :user_id, title: :title, body: :body}#@json_to_local_hash

    def post_parameters
      {}.tap do |params|
        true_class.json_to_local.keys.map do |json_key|
          local_key = true_class.json_to_local[json_key]
          attribute_value = send("#{local_key}")
          params[json_key] = attribute_value unless attribute_value.nil?
        end
      end
    end
  end
end
