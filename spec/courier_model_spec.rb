# describe "The Courier Base Object" do
#   it "returns a CoreData::Model on .new" do
#     class Person < Courier::Base; end
#     person = Person.new
#     person.class.ancestors.should.include(CoreData::Model)
#   end
# 
#   # it "is a descendant of CoreData::ModelDefinition" do
#   #   @object = Courier::Base.new
#   #   @object.class.ancestors.should.include(CoreData::ModelDefinition)
#   # end
# end

# class Player < Courier::Base
#   belongs_to :team, class: Team, inverse: :players
#
#   validation :do_something, on: :create
#   def do_something; end
#
#   property :name, default: "Nick",
#                   required: true
# end
#
# class Team < Courier::Base
#   has_many :players, class: Player, inverse: :team,
#               order: ['name', :desc]
# end
#
#
# Events
# --
# create, save, delete
# (later) fetch
