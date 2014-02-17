class Thing < Courier::Base
  belongs_to :person, as: :owner, on_delete: :nullify

  property :name, CoreData::PropertyTypes::String
end

class Person < Courier::Base
  has_many :things, as: :toys, on_delete: :cascade

  property :name, CoreData::PropertyTypes::String
end

# class Person < Courier::Base
#   property :name, CoreData::PropertyTypes::String
# end

C = Courier::Courier.instance

# class Person < CoreData::Model; end
# class Toy < CoreData::Model; end

class AppDelegate
  def application(_, didFinishLaunchingWithOptions:_)
    courier = Courier::Courier.instance

    courier.parcels = [Person, Thing]

    # # courier.parcels = [Person]

    # # person = Person.create
    # # person.name = "Nick"
    # # person.save

    # # all_people = Person.all
    # # unless all_people.nil?
    # #   puts "all people: #{all_people.map{|p|p.name}.inspect}"
    # # end

    # # schema_description = CoreData::SchemaDescription.load(Courier::SchemaSaveName)
    # # schema = schema_description.to_schema
    # # puts schema_description.describe

    # db_stuff

    true
  end

  # def db_stuff
  #   Courier::nuke.everything.right.now

  #   # to avoid collisions when establishing a relationship:
  #   # schema generation order:
  #   #   1. instantiate all model definitions
  #   #   2. instantiate all relationships (name, destination_model, min/max, delete)
  #   #   3. now set all inverse_relationship's

  #   person_model = CoreData::ModelDefinition.new
  #   person_model.name = "Person"
  #   person_model.model = Person

  #   toy_model = CoreData::ModelDefinition.new
  #   toy_model.name = "Toy"
  #   toy_model.model = Toy

  #   owner = CoreData::RelationshipDefinition.new
  #   owner.name = "owner"
  #   owner.destination_model = person_model
  #   owner.min_count = 0
  #   owner.max_count = 1
  #   owner.delete_rule = CoreData::DeleteRule::Nullify

  #   toys = CoreData::RelationshipDefinition.new
  #   toys.name = "toys"
  #   toys.destination_model = toy_model
  #   toys.min_count = 0
  #   toys.max_count = 0
  #   toys.delete_rule = CoreData::DeleteRule::Cascade

  #   toy_name = CoreData::PropertyDefinition.new
  #   toy_name.name = "name"
  #   toy_name.type = CoreData::PropertyTypes::String

  #   person_name = CoreData::PropertyDefinition.new
  #   person_name.name = "name"
  #   person_name.type = CoreData::PropertyTypes::String

  #   toy_model.properties = [toy_name, owner]
  #   person_model.properties = [person_name, toys]

  #   owner.inverse_relationship = toys
  #   toys.inverse_relationship = owner

  #   schema = CoreData::Schema.new
  #   schema.entities = [person_model, toy_model]
  #   store_coordinator = CoreData::StoreCoordinator.new(schema)
  #   store_coordinator.add_store_named("default")
  #   context = CoreData::Context.new
  #   context.store_coordinator = store_coordinator

  #   person = context.create(Person)
  #   toy = context.create(Toy)

  #   another_toy = context.create(Toy)
  #   another_toy.name = "Scannerz"

  #   person.name = "Nick"
  #   toy.name = "Bopit"

  #   toy.owner = person
  #   context.save
  #   puts "saved."

  #   people = Person.all(context)
  #   toys = people.first.toys.allObjects
  #   puts "first person's toys: #{toys.map{ |t| t.name }.join(', ')}"
  #   puts "all people's toys: #{Toy.all(context).map{ |t| t.name }.join(', ')}"

  #   schema_description = CoreData::SchemaDescription.new(schema)
  #   puts "#{schema_description.describe}"
  # end
end
