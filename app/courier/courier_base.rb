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

    def self.property(*property)
      properties << coredata_property_from(property)
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

    def self.all
      super(Courier.instance.contexts[:main])
    end

    def save
      Courier.instance.contexts[:main].save
    end

    def delete
      Courier.instance.contexts[:main].deleteObject(self)
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

    def where(*conditions)
    end
  end
end
