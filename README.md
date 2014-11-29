# Courier

![courier](http://i.imgur.com/oPRkxzL.png)

A Rubymotion wrapper for syncing JSON resources to Core Data.

[Check out the example app](https://github.com/pachun/ExampleCourierApp)

[Also, a short blog post](http://pachun.roon.io/courier)

[![Code Climate](https://codeclimate.com/github/pachun/Courier/badges/gpa.svg)](https://codeclimate.com/github/pachun/Courier)

--
###Setup
Gemfile

```ruby
gem 'afmotion'
gem 'motion-courier', '~>0.5.2', git: 'https://github.com/pachun/Courier'
```

```
bundle exec rake pod:install
bundle
```

--
###Models Quickly

```ruby
class League < Courier::Base
  has_many :teams, as: :teams, on_delete: :cascade, inverse_name: :league
  has_many :players, through: [:teams, :players]

  attr_accessor :unpersisted_variables_here, :commissioner
end

class Team < Courier::Base
  belongs_to :league, as: :league, on_delete: :nullify, inverse_name: :teams
  has_many :players, as: :players, on_delete: :nullify, inverse_name: :team

  property :id, Integer32, required: true, key: true
  property :name, String
  property :location, String

  self.json_to_local = {:ID => :id, :TeamName => :name, :TeamTown => :location}
  self.collection_path = "teams/"
  self.individual_path = "teams/:id"
end

class Player < Courier::Base
  belongs_to :team, as: :team, on_delete: :nullify, inverse_name: :players

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
team.add_to_players(Player.create)    # either
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
  belongs_to :team, as: :team, on_delete: :nullify, inverse_name: :players

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
  has_many :players, as: players, on_delete: :nullify, inverse_name: :team
  property :id, Integer32, key: true
  property :name, String
  property :location, String
  
  self.json_to_local = {:ID => :id, :TeamName => :name, :TeamTown => :location}
  self.collection_path = "teams/"
  self.individual_path = "teams/:id"
end

class Player < Courier::Base
  belongs_to :team, as: :team, on_delete: :nullify, inverse_name: :players
  property :id, Integer32, key: true
  property :name, String
end

Courier::Courier.instance.url = "http://hello.world.me"
Courier::Courier.instance.parcels = [Team, Player]
```

Fetching single resources
```ruby
# pass in anything needed to resolve the individual_path set before
Team.find(id: 5) do |response|
  if response.success?
    response.resource # fetched resource
    response.resource.merge_if { conditional } # do things with it
  else
    response.error_message # useful information
  end
end
```

Fetching a collection of resources
```ruby
Team.find_all do |response|
  # response[:response].success? returns true/false ([:response] is the AFMotion response)
  # response[:error_message] is an error message, if there was a problem
  # response[:conflicts] will be an array, in this format:
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

  response[:conflicts].each do |conflict|
    conflict[:foreign].merge_if do
      # true or false
    end
  end

  # or you could add "conflict_policy :overwrite_local" to the team model to automatically do
  # what was formerly accomplished with the following:
  response[:conflicts].each do |conflict|
    conflict[:foreign].merge!
  end
  # you can still do this, but I think the conflict_policy route is cleaner
end
```

Fetching has_many related resources:
```ruby
# getting all the players on a team
team = Team.create
team.id = 1
team.find_players do |response| # endpoint inferred to be /teams/1/players (based on collection/individual url settings)
  # response[:conflicts] will be an array of players this time:
  #
  # [
  #   {
  #     local: <PlayerInstance0x123>,
  #     foreign: <PlayerInstance0x456>,
  #   },
  #   {
  #     local: <PlayerInstance0x789>,
  #     foreign: <PlayerInstance0x012>,
  #   },
  #   {
  #     local: <PlayerInstance0x345>,
  #     foreign: <PlayerInstance0x678>,
  #   }
  # ]
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
