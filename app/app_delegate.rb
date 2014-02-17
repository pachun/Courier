# class Thing < Courier::Base
#   belongs_to :person, as: :owner, on_delete: :nullify
# end
# 
# class Person < Courier::Base
#   has_many :things, as: :toys, on_delete: :cascade
# 
#   property :name, CoreData::PropertyTypes::String
# end

# class Person < Courier::Base
#   property :name, CoreData::PropertyTypes::String
# end

# C = Courier::Courier.instance

class AppDelegate
  def application(_, didFinishLaunchingWithOptions:_)
    # courier = Courier::Courier.instance

    # courier.parcels = [Person, Thing]

    # courier.parcels = [Person]

    # person = Person.create
    # person.name = "Chris"
    # person.save

    # all_people = Person.all
    # unless all_people.nil?
    #   puts "all people: #{all_people.map{|p|p.name}.inspect}"
    # end

    # schema_description = CoreData::SchemaDescription.load(Courier::SchemaSaveName)
    # schema = schema_description.to_schema
    # puts schema_description.describe

    true
  end
end
