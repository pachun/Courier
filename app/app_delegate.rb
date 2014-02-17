class Person < CoreData::Model
end

class Toy < CoreData::Model
end

class Game
  attr_accessor :name, :release_year

  def encodeWithCoder(encoder)
    encoder.encodeObject(@name, forKey:"name")
    encoder.encodeObject(@release_year, forKey:"release_year")
  end

  def initWithCoder(decoder)
    @name = decoder.decodeObjectForKey("name")
    @release_year = decoder.decodeObjectForKey("release_year")
    init
  end

  def save(url)
    data = NSKeyedArchiver.archivedDataWithRootObject(self)
    written = data.writeToURL(url, options:NSDataWritingAtomic, error:nil)
    puts "hooray" if written
  end
end

class AppDelegate
  def application(_, didFinishLaunchingWithOptions:_)
    # db_stuff
    true
  end

  def nscoder_stuff
    url = db_url("game.data")

    game = Game.new
    game.name = "Call of Duty - Ghost Protocol"
    game.release_year = 2013
    game.save(url)

    data = NSData.dataWithContentsOfFile(url, options:NSDataReadingMappedIfSafe, error:nil)
    same_game = NSKeyedUnarchiver.unarchiveObjectWithData(data)
    puts "same game is #{same_game.name} from #{same_game.release_year}"
  end

  def db_stuff
    erase_old_db

    # to avoid collisions when establishing a relationship:
    # schema generation order:
    #   1. instantiate all model definitions
    #   2. instantiate all relationships (name, destination_model, min/max, delete)
    #   3. now set all inverse_relationship's

    person_model = CoreData::ModelDefinition.new
    person_model.name = "Person"
    person_model.model = Person

    toy_model = CoreData::ModelDefinition.new
    toy_model.name = "Toy"
    toy_model.model = Toy

    owner = CoreData::RelationshipDefinition.new
    owner.name = "owner"
    owner.destination_model = person_model
    owner.min_count = 0
    owner.max_count = 1
    owner.delete_rule = CoreData::DeleteRule::Nullify

    toys = CoreData::RelationshipDefinition.new
    toys.name = "toys"
    toys.destination_model = toy_model
    toys.min_count = 0
    toys.max_count = 0
    toys.delete_rule = CoreData::DeleteRule::Cascade

    toy_name = CoreData::PropertyDefinition.new
    toy_name.name = "name"
    toy_name.type = CoreData::PropertyTypes::String

    person_name = CoreData::PropertyDefinition.new
    person_name.name = "name"
    person_name.type = CoreData::PropertyTypes::String

    toy_model.properties = [toy_name, owner]
    person_model.properties = [person_name, toys]

    owner.inverse_relationship = toys
    toys.inverse_relationship = owner

    schema = CoreData::Schema.new
    schema.entities = [person_model, toy_model]
    store_coordinator = CoreData::StoreCoordinator.new(schema)
    store_coordinator.add_store_named("default")
    context = CoreData::Context.new
    context.store_coordinator = store_coordinator

    # person = context.create(Person)
    # toy = context.create(Toy)

    # another_toy = context.create(Toy)
    # another_toy.name = "Scannerz"

    # person.name = "Nick"
    # toy.name = "Bopit"

    # toy.owner = person
    # context.save
    # puts "saved."

    # people = Person.all(context)
    # toys = people.first.toys.allObjects
    # puts "first person's toys: #{toys.map{ |t| t.name }.join(', ')}"
    # puts "all people's toys: #{Toy.all(context).map{ |t| t.name }.join(', ')}"

    schema_description = CoreData::SchemaDescription.new(schema)
    puts "#{schema_description.describe}"
  end

  # MIGRATION WORKING HERE:
  def run_migration
    erase_old_db

    # id attribute
    person_id = CoreData::PropertyDefinition.new
    person_id.name = "id"
    person_id.type = CoreData::PropertyTypes::Integer32

    # name attribute
    person_name = CoreData::PropertyDefinition.new
    person_name.name = "name"
    person_name.type = CoreData::PropertyTypes::String

    # 2nd id attribute
    person_id2 = CoreData::PropertyDefinition.new
    person_id2.name = "id"
    person_id2.type = CoreData::PropertyTypes::Integer32

    # 2nd name attribute
    person_name2 = CoreData::PropertyDefinition.new
    person_name2.name = "name"
    person_name2.type = CoreData::PropertyTypes::String

    # age attribute
    person_age = CoreData::PropertyDefinition.new
    person_age.name = "age"
    person_age.type = CoreData::PropertyTypes::Integer16

    # frist PERSON model
    person_model_definition = CoreData::ModelDefinition.new
    person_model_definition.name = "Person"
    person_model_definition.model = Person
    person_model_definition.properties = [person_id, person_name]

    # second PERSON model
    new_person_model_definition = CoreData::ModelDefinition.new
    new_person_model_definition.name = "Person"
    new_person_model_definition.model = Person
    new_person_model_definition.properties = [person_id2, person_name2, person_age]

    # schema v1
    schema = CoreData::Schema.new
    schema.entities = [person_model_definition]
    store_coordinator = CoreData::StoreCoordinator.new(schema)
    store_coordinator.add_store_named("default")
    context = CoreData::Context.new
    context.store_coordinator = store_coordinator

    # schema v2
    new_schema = CoreData::Schema.new
    new_schema.entities = [new_person_model_definition]
    puts "new schema Person entity properties: #{new_schema.entities.first.properties.map{ |p| p.name }.join(",")}"

    # create & save a person in schema 1
    some_person = context.create(Person)
    some_person.id = 5
    some_person.name = "Nick"
    context.save
    puts "People in core data (before migration):"
    people = Person.all(context)
    people.each do |p|
      puts "#{p.name} with id #{p.id}"
    end

    # migrate to schema 2
    error = Pointer.new(:object)
    mapping_model = NSMappingModel.inferredMappingModelForSourceModel(schema, destinationModel:new_schema, error:error)
    if mapping_model.nil?
      puts "no lightweight migration possible"
    else
      puts "using lightweight migration"
    end

    error = Pointer.new(:object)
    migration_manager = NSMigrationManager.alloc.initWithSourceModel(schema, destinationModel:new_schema)
    migrated = migration_manager.migrateStoreFromURL(db_url("default.sqlite"),
                                                     type:NSSQLiteStoreType,
                                                     options:nil,
                                                     withMappingModel:mapping_model,
                                                     toDestinationURL:db_url("default2.sqlite"),
                                                     destinationType:NSSQLiteStoreType,
                                                     destinationOptions:nil,
                                                     error:error)

    new_store_coordinator = CoreData::StoreCoordinator.new(new_schema)
    new_store_coordinator.add_store_named("default2")
    new_context = CoreData::Context.new
    new_context.store_coordinator = new_store_coordinator

    if migrated
      puts "People in core data (after migration):"
      people = Person.all(new_context)
      people.each do |p|
        p.age = 22
        puts "#{p.name} with id #{p.id} and age #{p.age}"
      end
    else
      puts "Migration failed: #{error[0].userInfo}"
    end
  end

  def erase_old_db
    NSFileManager.defaultManager.removeItemAtPath(db_url("default.sqlite"), error:nil)
    NSFileManager.defaultManager.removeItemAtPath(db_url("default2.sqlite"), error:nil)
  end

  def db_url(name)
    app_documents_path = NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains:NSUserDomainMask).last
    app_documents_path.URLByAppendingPathComponent(name)
  end
end
