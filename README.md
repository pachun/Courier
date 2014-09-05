# Courier
![courier](http://i.imgur.com/oPRkxzL.png)

A Rubymotion wrapper for syncing JSON resources to Core Data.

--
###Setup
Gemfile

```ruby
gem 'motion-support', require: false
gem 'afmotion', '~> 2.0.0'
gem 'motion-courier', '~>0.1.9', git: 'https://github.com/pachun/Courier'
```

Rakefile

```ruby
require 'motion-support/inflector'
```

I'm having trouble automating the inclusion of afmotion and motion-support on gem inclusion. If anyone knows how, please
send me a pull request or take the time to let me know how - hello@nickpachulski.com.

--
###Models Quickly

```ruby
class League < Courier::Base
  has_many :teams, as: :teams, on_delete: :cascade
  has_many :players, through: [:teams, :players]

  attr_accessor :unpersisted_variables_here, :commissioner
end

class Team < Courier::Base
  belongs_to :league, as: :league, on_delete: :nullify
  has_many :players, as: :players, on_delete: :nullify

  property :id, Integer32, required: true, key: true
  property :name, String
  property :location, String

  self.json_to_local = {:ID => :id, :TeamName => :name, :TeamTown => :location}
  self.collection_path = "teams/"
  self.individual_path = "teams/:id"
end

class Player < Courier::Base
  belongs_to :team, as: :team, on_delete: :nullify

  property :id, Integer32, required: true
  property :name, String, required: true, default_value: "Unknown"
  property :age, Integer16
  property :num_championships, Integer16

  scope :seasoned, :or => [ :and => ["age >= 40", "num_championships >= 2"],
                            :and => ["age >= 30", "num_championships >= 4"],
                          ]
end
```
--
###Schema
Defining the models doesn't implicitly define a schema (managed object model)
for you. You have to tell Courier the names of the models. You use the singleton instance's parcels=() to do that.

```ruby
class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    Courier::Courier.instance.parcels = [League, Team, Player]
    true
  end
end
```

--
###Tests

Every rspec test that wants to initialize a new schema should begin with the line

```ruby
Courier::nuke.everything.right.now
```
This erases the old store completely.

```ruby
describe "The Courier Base Class" do
  before do
    Courier::nuke.everything.right.now
    Object.send(:remove_const, :Keyboard) if Object.constants.include?(:Keyboard)

    class Keyboard < Courier::Base; end
    Courier::Courier.instance.parcels = [Keyboard]
  end
end
```

If you're declaring Courier::Base models in any block that'll be run twice, during your test suite, courier::base tries to re-register the class with core data, which will error because one by that name was already registered. Therefor, you should delete the old class constant prior to your new class definition.

--
### Fixtures

```ruby
class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    Courier::nuke.everything.right.now
    Courier::Courier.instance.parcels = [League, Team, Player]
    Fixtures::seed_players
    true
  end
end

module Fixtures
  def self.seed_players
    ["Nick", "Chris", "Matt", "Josh"].each_with_index do |name, pos|
      p = Player.create
      p.id = pos
      p.name = name
    end
    Courier::Courier.instance.save
  end
end
```

You could maybe pass in a flag on the command line to execute the fixture
method.

--
###Create, Save, and Delete
.create() will create a model instance, but it will not be persisted to
subsequent app runs. Calling .save() on the Courier singleton will persist everything created up to that point
```ruby
p1 = Person.create
p1.name = "John"
p2 = Person.create
Courier::Courier.instance.save
```

.delete() is similar to create in that it will delete the model in the context of the current app run,
but the deletion won't be persisted in successive app runs, unless you also call .save() is called on the courier instance after .delete() is called on the object. (.delete!() exists and is different from .delete(); don't ever call .delete!() on an object created with .create())

--
###Loading from Core Data
.all on a subclass of Courier::Base will return an array of all the created models. eg

```ruby
Player.all # => [<Player1>, <Player2>, etc]
```

To set relationships, you can do

```ruby
team = Team.create
some_player = Player.create
team.players << Player.create         # either
some_player.team = team               # or
team.players # => [those 2 players]   # both work exactly the same
```

If a league has many teams, and a team has many players, define a league has many players through teams as shown in the first README.md model, to get this shortcut

```ruby
league.players
```

--
###Named Scopes
You saw one earlier in the player model:

```ruby
class Player < Courier::Base
  belongs_to :team, as: :team, on_delete: :nullify

  property :id, Integer32, required: true
  property :name, String, required: true, default_value: "Unknown"
  property :age, Integer16
  property :num_championships, Integer16

  scope :seasoned, :or => [ :and => ["age >= 40", "num_championships >= 2"],
                            :and => ["age >= 30", "num_championships >= 4"],
                          ]
end
```

You can nest those as deeply as you want, and there's a lot of them. Check out
the courier_scope_spec.rb file to see them all. [Everything in
here](https://developer.apple.com/library/mac/documentation/cocoa/conceptual/predicates/Articles/pSyntax.html)
is provisioned for by [the Courier::Scope module](https://github.com/pachun/Courier/blob/master/app/courier/scope.rb).
Some of the string comparisons like LIKE to find a string that contains another
string can be tricky to use with those "x >= y" string format of comparison
above. If you need to be really specific you can use
```ruby
scope :males_and_doctors_whos_names_start_with_mc, Courier::Scope.where(:name, contains: "r. Mc")
```
(for example) to search for names that have either Dr. Mc or
Mr. Mc. A list of those and examples on how to use each of them is also in the
courier_scope_spec.rb file.

--
###Dynamic Scopes

```ruby
seasoned_scope = Courier::Scope.where(:or => [ :and => ["age >= 40", "num_championships >= 2"],
                                               :and => ["age >= 30", "num_championships >= 4"],
                                      ])
team.players.where(seasoned_scope) # => [player1, player2, etc]
```

--
###JSON Resources

```ruby
class Team < Courier::Base
  has_many :players, as: players, on_delete: :nullify
  property :id, Integer32, key: true
  property :name, String
  property :location, String
  
  self.json_to_local = {:ID => :id, :TeamName => :name, :TeamTown => :location}
  self.collection_path = "teams/"
  self.individual_path = "teams/:id"
end

class Player < Courier::Base
  belongs_to :team, as: :team, on_delete: :nullify
  property :id, Integer32, key: true
  property :name, String
end

Courier::Courier.instance.url = "http://hello.world.me"
Courier::Courier.instance.parcels = [Team, Player]
```

Fetching single resources
```ruby
team = Team.new
team.id = 5
team.fetch do |foreign_team| # asyncly called after http get
  foreign_team.merge_if do
    # return true in this block to overwrite the local team with id 5 with the fetched team
  end

  # if you want to just save a certain attribute of the fetched resource, then do this instead:
  team.name = foreign_team.name
  team.save
  foreign_team.delete! # if you don't use .merge!, or .merge_if(&block), then delete! the foreign resource (or you'll get memory leaks)
end

team.fetch! {} # foreign team w/ id=5 auto overwrites local w/ id=5, then your block executes
```

Fetching a collection of resources
```ruby
Team.fetch do |conflicts|
  # conflicts will be an array, in this format:
  #
  # [
  #   {
  #     local: <TeamInstance0x123>,
  #     foreign: <TeamInstance0x456>,
  #   },
  #   {
  #     local: <TeamInstance0x789>,
  #     foreign: <TeamInstance0x012>,
  #   },
  #   {
  #     local: <TeamInstance0x345>,
  #     foreign: <TeamInstance0x678>,
  #   }
  # ]
  #
  # resolve the conflicts one at a time the same way you would with single resources

  conflicts.each do |conflict|
    conflict[:foreign].merge_if do
      # true or false
    end
  end

  # or you could do

  conflicts.each do |conflict|
    conflict[:foreign].merge!
  end
end
```

Fetching has_many related resources:
```ruby
# getting all the players on a team
team = Team.create
team.id = 1
team.fetch_players do |conflicts| # endpoint inferred to be /teams/1/players
  # conflicts will be an array of players this time:
  #
  # [
  #   {
  #     local: <TeamInstance0x123>,
  #     foreign: <TeamInstance0x456>,
  #   },
  #   {
  #     local: <TeamInstance0x789>,
  #     foreign: <TeamInstance0x012>,
  #   },
  #   {
  #     local: <TeamInstance0x345>,
  #     foreign: <TeamInstance0x678>,
  #   }
  # ]
end
```

Fetching belongs_to related resources:
```ruby
team = Team.create
team.id = some_player.team_id
team.fetch do |foreign_team|
  # merge as you would (remembering to .delete! if necessary!)
end
```

Pushing single resources back up to the server
```ruby
  team.push do |result|
    if result.success?
      # worked
    else
      # uh oh
      puts "#{result.operation.response.statusCode.to_s}"
    end
  end
```

--
###To Do

* Remove need for .save call.

* [lightweight](https://developer.apple.com/library/ios/documentation/cocoa/conceptual/CoreDataVersioning/Articles/vmLightweightMigration.html) command line migrations.
