# Courier
![courier](http://i.imgur.com/oPRkxzL.png)

A Rubymotion wrapper for syncing JSON resources to Core Data.

--
###Setup
Gemfile

```ruby
gem 'motion-courier', '~>0.0.5', git: 'https://github.com/pachun/Courier'
```

Rakefile

```ruby
require 'motion-support/inflector'
require 'bubble-wrap/http'
```

I'm having trouble automating that on gem inclusion. If anyone knows how, please
send me a pull request or take the time to let me know how -
hello@nickpachulski.com.

--
###Models
Here's a succinct illustration of most features:

```ruby
class League < Courier::Base
  has_many :teams, as: :teams, on_delete: :cascade
  has_many :players, through: [:teams, :players]
  
  attr_accessor :unpersisted_variables_here, :commissioner
end

class Team < Courier::Base
  belongs_to :league, as: :league, on_delete: :nullify
  has_many :players, as: :players, on_delete: :nullify

  property :id, Integer32, required: true
  property :name, String
  property :location, String

  self.json_to_local = {:ID => :id, :TeamName => :name, :TeamTown => :location}
  self.collection_url = "teams/"
  self.individual_url = "teams/:id"
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
for you. You have to tell Courier the names of the models. You use the singleton
courier instance to do that.

```ruby
C = Courier::Courier.instance

class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    C.parcels = [League, Team, Player]
    true
  end
end
```
I do this in my app delegate, so I can say C instead of
Courier::Courier.instance from then on. You can also get a string description of
the schema with .schema
```ruby
puts "#{Courier::Courier.instance.schema}"
```
![schema](http://i.imgur.com/77G9QGR.png)

--
###Tests
If you're doing a lot of testing, you probably want to clear old tests data out
and start with a fresh instance, or with some fixtures. There's a way to clear
the schema and empty the database

```ruby
Courier::nuke.everything.right.now
```

It's intentionally long so you don't type it by accident in a production app and
lose your db. Anyway, throwing this in a before block is a good way to test core
data with different schemas and clean slate databases. The courier_base_spec.rb
has a good example of using this:

```ruby
describe "The Courier Base Class" do
  before do
    Courier::nuke.everything.right.now
    Object.send(:remove_const, :Keyboard) if
Object.constants.include?(:Keyboard)

    class Keyboard < Courier::Base; end
    Courier::Courier.instance.parcels = [Keyboard]
  end
end
```

Also of note, the remove_const lines. If you're declaring Courier::Base models
in any block that'll be run twice, courier::base tries to re-register the class
with core data, which will error because one by that name was already
registered. If you delete the constant, it fixes the problem.

--
### Fixtures
There's nothing special courier gives you for fixtures, but they're easy to
create.

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
subsequent app runs until .save() is called. You can call .save on the model
itself, or on the Courier::Courier.instance. __Those both do the same thing.__
.save() called on anything, saves every model .create()'d up to the point, eg:

```ruby
p1 = Player.create
p2 = Player.create
p2.save
```

Saves p1 and p2. So I like to use the Courier::Courier.instance.save method
instead. Even though it's longer, it's more clear what's happening.

.delete() is similar to create. It will delete the model in the current app run,
but it will be persisted in the following app run, unless you also call .save()
afterwards.

--
###Loading from Core Data
Calling .all on a model will return an array of all the saved models. eg

```ruby
Player.all # => [<Player1>, <Player2>, etc]
```

If you have relationships like a team having many players, you can also do
things like:

```ruby
team = Team.create
some_player = Player.create
team.players << Player.create         # either
some_player.team = team               # or
team.players # => [those 2 players]   # both work exactly the same
```

Remember to call save to persist those models/relationships. The same applies to
has_many:through: relationships. Similarly, if a team has_many players through
team players, you can do

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
the courier_scope_spec.rb file to see them all. [Everything in here is
provisioned for by the Courier::Scope
module](https://developer.apple.com/library/mac/documentation/cocoa/conceptual/predicates/Articles/pSyntax.html).
Some of the string comparisons like LIKE to find a string that contains another
string can be tricky to use with those "x >= y" string format of comparison
above. If you need to be really specific you can use Courier::Scope.where(:name,
contains: "r. Mc") (for example) to search for names that have either Dr. Mc or
Mr. Mc. A list of those and examples on how to use each of them is also in the
courier_scope_spec.rb file.

--
###Dynamic Scopes

```ruby
my_scope = Courier::Scope.where(:or => [ :and => ["age >= 40",
"num_championships >= 2"],
                                         :and => ["age >= 30",
"num_championships >= 4"],
                                ])
team.players.where(my_scope) # => [player1, player2, etc]
```

--
###JSON Resources
Set the base url on courier's instance, and the resource path on the model:

```ruby
class Team < Courier::Base
  self.json_to_local = {:ID => :id, :TeamName => :name, :TeamTown => :location}
  self.collection_url = "teams/"
  self.individual_url = "teams/:id"
end

Courier::Courier.instance.url = "http://hello.world.me"
```

You can then do:

```ruby
team = Team.new
team.id = 5
team.fetch do
  # executed after the http request has completed
  team.save
end
```

To get all teams, you can do

```ruby
Team.fetch_all do
  Courier::Courier.instance.save
end
```



--
###To Do

* Been working really hard on getting
* [lightweight](https://developer.apple.com/library/ios/documentation/cocoa/conceptual/CoreDataVersioning/Articles/vmLightweightMigration.html)
* command line migrations working.
* Replace Bubble-Wrap/http with AFMotion
* Remove need for .save call, by creating an independent context for each object
* .create'd and then merging it into the main context when it's required fields
* are all satisfied.
* Validations with custom "fix" messages
* Some kind of auto-resolution for fetching a bunch of object from a json
* endpoint, when they already exist locally. Should have a field designated as
* :key or something.
