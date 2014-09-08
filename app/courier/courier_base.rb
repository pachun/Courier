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

    # Setting the owner_class and owned_classes as a String for now,
    # to be constantized! later. Can't do it here, because one class
    # is always defined at this point, and the other is not yet.
    #
    # "constantization" and hemming of inverse relationships will
    # happen just before a store_coordinator is generated from the
    # schema (in courier.rb)
    def self.belongs_to(owner_class, as:name, on_delete:deletion_rule, inverse_name:inverse_name)
      belongs_to = {min:0, max:1}
      owner_class = owner_class.to_s.capitalize
      owned_class = self.to_s
      relationships << CoreData::RelationshipDefinition.from(belongs_to, owned_class, owner_class, name, deletion_rule, inverse_name)
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

    def self.has_many(owned_class_plural_symbol, as:name, on_delete:deletion_rule, inverse_name:inverse_name)
      owned_class_string = owned_class_plural_symbol.to_s.singularize.capitalize

      # set the relationship
      has_many = {min:0, max:0}
      owner_class_string = self.to_s
      relationship = CoreData::RelationshipDefinition.from(has_many, owner_class_string, owned_class_string, "#{name}__", deletion_rule, inverse_name)
      relationships << relationship

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
      define_method("add_to_#{name}") do |x|
        owner_instance = self
        x.send("#{relationship.inverse_relationship.name}=", owner_instance)
      end

      # e.g. defines .posts_path on User instances if User has_many :posts
      define_method("#{owned_class_plural_symbol}_url") do
        owned_class = owned_class_string.constantize
        self.individual_url + "/" + owned_class.collection_path
      end

      define_method("fetch_#{name}") do |&block|
        owned_class = owned_class_string.constantize
        nested_collection_path = self.send("#{owned_class_pural_symbol}_url")
        inverse_relationship_name = relationship.inverse_relationship.name
        owned_class.fetch_location(
          endpoint: nested_collection_path,
          owner_instance: self,
          relation_name: inverse_relationship_name,
          related_model_class: relationship.local_model,
          &block)
      end
    end

    def self.create
      Courier.instance.contexts[:main].create(self.to_s).tap do |i|
        i.merge_relationships = []
      end
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

    @individual_path = ""
    @collection_path = ""
    @json_to_local = ""
    def self.individual_path=(path)
      @individual_path = path
    end

    def self.collection_path=(path)
      @collection_path = path
    end

    def self.json_to_local=(mapping)
      @json_to_local = mapping
    end

    def self.individual_path
      @individual_path
    end

    def self.collection_path
      @collection_path
    end

    def self.json_to_local
      @json_to_local
    end

    # group resource fetch

    def self.fetch(&block)
      fetch_location(endpoint:collection_url, &block)
    end

    def self.fetch_location(fetch_params, &block)
      AFMotion::HTTP.get(fetch_params[:endpoint]) do |result|
        if result.success?
          fetch_params[:json] = result.object
          _compare_local_collection_to_fetched_collection(fetch_params, &block)
        else
          puts "error while fetched collection of #{self.to_s.pluralize}: #{result.error.localizedDescription}"
        end
      end
    end

    def self._compare_local_collection_to_fetched_collection(fetch_params, &block)
      block.call( curate_conflicts(fetch_params) )
    end

    def self.curate_conflicts(fetch_params)
      conflicts = fetch_params[:json].map do |foreign_resource_json|
        if fetch_params.has_key?(:related_model_class)
          foreign_resource = fetch_params[:related_model_class].send("create_in_new_context")
        else
          foreign_resource = create_in_new_context
        end
        bind(foreign_resource, to: fetch_params[:owner_instance], as: fetch_params[:relation_name])
        save_json(foreign_resource_json, to: foreign_resource)
        local_resource = foreign_resource.main_context_match
        {local: local_resource, foreign: foreign_resource}
      end
    end

    def self.bind(related_resource, to: owner, as: relation_name)
      unless owner.nil?
        related_resource.merge_relationships << {relation: "#{relation_name}=", relative: owner}
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
      deleting_existing_resource = !counterpart.nil?
      counterpart ||= true_class.create
      true_class.properties.each do |p|
        counterpart.send("#{p.name}=", send("#{p.name}"))
      end
      merge_relationships.each do |r|
        counterpart.send(r[:relation], r[:relative])
      end
      delete!
      deleting_existing_resource
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
