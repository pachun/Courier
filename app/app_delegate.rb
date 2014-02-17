# class Thing < Courier::Base
#   belongs_to :person, on_delete: :nullify
# end
# 
# class Person < Courier::Base
#   has_many :things, on_delete: :cascade
# 
#   property :name, CoreData::PropertyTypes::String
# end

class Person < Courier::Base
  property :name, CoreData::PropertyTypes::String
end

class AppDelegate
  def application(_, didFinishLaunchingWithOptions:_)
    courier = Courier::Courier.instance

    # courier.parcels = [Person, Thing]

    courier.parcels = [Person]

    person = Person.create
    person.name = "Chris"
    person.save

    all_people = Person.all
    puts "all people: #{all_people.map{|p|p.name}.inspect}"

    # schema_description = CoreData::SchemaDescription.load(Courier::SchemaSaveName)
    # schema = schema_description.to_schema
    # puts schema_description.describe

    true
  end
end
