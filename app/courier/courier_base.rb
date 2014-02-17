module Courier
  class Base < CoreData::Model

    def self.to_coredata
      @coredata_definition ||= CoreData::ModelDefinition.new.tap do |m|
        m.name = self.to_s
        m.model = self
        m.properties = @properties# + @relationships
      end
    end

    def self.property(*property)
      @properties ||= []
      @properties << coredata_property_from(property)
    end

#     def self.belongs_to(owner_class, on_delete:delete_action)
#       @relationships ||= []
#       @relationships << coredata_belongs_to_with(owner_class, delete_action)
#     end
# 
#     def self.has_many(owned_class, on_delete:delete_action)
#       @relationships ||= []
#       @relationships << coredata_has_many_with(owned_class, delete_action)
#     end
# 
#     def self.coredata_has_many_with(owned_class, delete_action)
# #       CoreData::RelationshipDefinition.new.tap do |r|
# #         r.name = owned_class.to_s
# #         r.destination_model = "Fixme later"
# #         r.min_count = 0
# #         r.max_count = 0
# #         r.delete_rule = CoreData::DeleteRule::from_symbol(delete_action)
# #       end
#     end
#     def self.coredata_belongs_to_with(owner_class, delete_action)
#     end

    def self.coredata_property_from(property)
      CoreData::PropertyDefinition.new.tap do |p|
        p.name = property[0]
        p.type = property[1]
      end
    end

    def self.create
      Courier.instance.contexts[:main].create(self.to_s)
    end

    def self.all
      super(Courier.instance.contexts[:main])
    end

    # def initialize
    #   puts "in here!"
    #   @relationships = []
    #   @properties = []
    #   super
    # end

    def save
      Courier.instance.contexts[:main].save
    end
  end
end
