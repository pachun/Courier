module Courier
  class Base < CoreData::Model
    attr_accessor :merge_relationships

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
      create_has_many_relation(owned_class_plural_symbol, as:name, on_delete:deletion_rule, inverse_name:inverse_name)
      define_array_getter(name)
      define_add_to_owners_collection(name)
      define_nested_resource_url(owned_class_plural_symbol)
      define_nested_fetch(name, owned_class_plural_symbol)
    end

    private

    def self.create_has_many_relation(owned_class_plural_symbol, as:name, on_delete:deletion_rule, inverse_name:inverse_name)
      has_many = {min:0, max:0}
      owner_class_string = self.to_s
      owned_class_string = owned_class_plural_symbol.to_s.singularize.capitalize
      relationship = CoreData::RelationshipDefinition.from(has_many, owner_class_string, owned_class_string, "#{name}__", deletion_rule, inverse_name)
      relationships << relationship
    end

    # if a keyboard has many keys, this provides keyboard.keys to return an array
    # of all the keys
    def self.define_array_getter(name)
      define_method("#{name}") do
        frozen_array = self.send("#{name}__").allObjects
        frozen_array.map{ |f| f }
      end
    end

    # this provides an alternative to setting a relationship from
    # the owned side; eg we can do
    #
    # keyboard.add_to_keys(key)
    #
    # instead of
    #
    # key.keyboard = keyboard
    #
    def self.define_add_to_owners_collection(name)
      relationship = relationships.last
      define_method("add_to_#{name}") do |x|
        owner_instance = self
        x.send("#{relationship.inverse_relationship.name}=", owner_instance)
      end
    end

    # e.g. defines .posts_url on User instances if User has_many :posts
    def self.define_nested_resource_url(owned_class_plural_symbol)
      define_method("#{owned_class_plural_symbol}_url") do
        owned_class = owned_class_plural_symbol.to_s.singularize.capitalize.constantize
        self.individual_url + "/" + owned_class.collection_path
      end
    end

    def self.define_nested_fetch(name, owned_class_plural_symbol)
      relationship = relationships.last
      define_method("fetch_#{name}") do |&block|
        owned_class = owned_class_plural_symbol.to_s.singularize.capitalize.constantize
        nested_collection_path = self.send("#{owned_class_plural_symbol}_url")
        inverse_relationship_name = relationship.inverse_relationship.name
        owned_class.fetch_location(
          endpoint: nested_collection_path,
          owner_instance: self,
          relation_name: inverse_relationship_name,
          related_model_class: relationship.local_model,
          &block
        )
      end
    end
  end
end
