# https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Predicates/Articles/pSyntax.html

describe "The Courier Scope Module" do
  it "defines .where(:attr, is: value)" do
    predicate = Courier::Scope.where(:name, is: "Nick")
    predicate.class.should == NSComparisonPredicate
    predicate.predicateFormat.should == "name == Nick"
  end

  it "defines .where(:attr, is_greater_than: value)" do
    predicate = Courier::Scope.where(:age, is_greater_than: 21)
    predicate.class.should == NSComparisonPredicate
    predicate.predicateFormat.should == "age > 21"
  end

  it "defines .where(:attr, is_greater_than_or_equal_to: value)" do
    predicate = Courier::Scope.where(:age, is_greater_than_or_equal_to: 21)
    predicate.class.should == NSComparisonPredicate
    predicate.predicateFormat.should == "age >= 21"
  end

  it "defines .where(:attr, is_less_than: value)" do
    predicate = Courier::Scope.where(:age, is_less_than: 18)
    predicate.class.should == NSComparisonPredicate
    predicate.predicateFormat.should == "age < 18"
  end

  it "defines .where(:attr, is_less_than_or_equal_to: value)" do
    predicate = Courier::Scope.where(:age, is_less_than_or_equal_to: 18)
    predicate.class.should == NSComparisonPredicate
    predicate.predicateFormat.should == "age <= 18"
  end

  it "defines .where(:attr, isnt: value)" do
    predicate = Courier::Scope.where(:status, isnt: :retired)
    predicate.predicateFormat.should == "status != retired"
  end

  it "defines .where(:attr, is_in: range)" do
    predicate = Courier::Scope.where(:age, is_in: [13,19])
    predicate.predicateFormat.should == "age BETWEEN {13, 19}"
  end

  it "defines .where(:attr, begins_with: value)" do
    predicate = Courier::Scope.where(:name, begins_with: "Dr. ")
    predicate.predicateFormat.should == %Q(name BEGINSWITH \"Dr. \")
  end

  it "defines .where(:attr, ends_with: value)" do
    predicate = Courier::Scope.where(:name, ends_with: "ski")
    predicate.predicateFormat.should == %Q(name ENDSWITH \"ski\")
  end

  it "defines .where(:attr, contains: value)" do
    predicate = Courier::Scope.where(:name, contains: "matt")
    predicate.predicateFormat.should == %Q(name CONTAINS \"matt\")
  end

  it "defines .where(:attr, is_similar_to: expression)" do
    predicate = Courier::Scope.where(:name, is_similar_to: "expression")
    predicate.predicateFormat.should == %Q(name LIKE \"expression\")
  end

  it "defines .where(:attr, fits: expression)" do
    predicate = Courier::Scope.where(:name, fits: "expression")
    predicate.predicateFormat.should == %Q(name MATCHES \"expression\")
  end

  it "defines .where(:attr, is_any_of: ['val1', 'val2'])" do
    predicate = Courier::Scope.where(:name, is_any_of: ["val1", "val2", "val3"])
    predicate.predicateFormat.should == %Q(name IN {"val1", "val2", "val3"})
  end

  it "defines .and(*predicates)" do
    predicate = Courier::Scope.and( [Courier::Scope.where(:name, is_any_of: ["Nick", "Chris", "Tom"]),
                                     Courier::Scope.where(:age, is_greater_than: 21),
                                     Courier::Scope.where(:personality, isnt: :childish)
    ])
    predicate.class.should == NSCompoundPredicate
  end

  it "defines .or(*predicates)" do
    predicate = Courier::Scope.or( [Courier::Scope.where(:name, is_any_of: ["Nick", "Chris", "Tom"]),
                                    Courier::Scope.where(:age, is_greater_than: 21),
                                    Courier::Scope.where(:personality, isnt: :childish)
    ])
    predicate.class.should == NSCompoundPredicate
  end

  it "defines .inverse(predicate)" do
    predicate = Courier::Scope.and( [Courier::Scope.where(:name, is_any_of: ["Nick", "Chris", "Tom"]),
                                         Courier::Scope.where(:age, is_greater_than: 21),
                                         Courier::Scope.where(:personality, isnt: :childish)
    ])
    inverse_predicate = Courier::Scope.inverse(predicate)
    inverse_predicate.class.should == NSCompoundPredicate
  end

  it "defines .from_string('attribute is value')" do
    scope = Courier::Scope.from_string("name is nick")
    scope.predicateFormat.should == "name == nick"
  end

  it "defines .from_string('attribute > value')" do
    predicate = Courier::Scope.from_string('age > 21')
    predicate.predicateFormat.should == "age > 21"
  end

  it "defines .from_string('attribute >= value')" do
    predicate = Courier::Scope.from_string('age >= 21')
    predicate.predicateFormat.should == "age >= 21"
  end

  it "defines .from_string('attribute < value')" do
    predicate = Courier::Scope.from_string('age < 21')
    predicate.predicateFormat.should == "age < 21"
  end

  it "defines .from_string('attribute <= value')" do
    predicate = Courier::Scope.from_string('age <= 21')
    predicate.predicateFormat.should == "age <= 21"
  end

  it "defines .from_string('attribute isnt value')" do
    predicate = Courier::Scope.from_string('status isnt retired')
    predicate.predicateFormat.should == "status != retired"
  end

  it "defines .from_string('attribute is_in value')" do
    predicate = Courier::Scope.from_string('age is_in [13,19]')
    predicate.predicateFormat.should == "age BETWEEN {13, 19}"
  end

  it "defines .from_string('attribute begins_with value')" do
    predicate = Courier::Scope.from_string('name begins_with Dr. P')
    predicate.predicateFormat.should == %Q(name BEGINSWITH \"Dr. P\")
  end

  it "defines .from_string('attribute ends_with value')" do
    predicate = Courier::Scope.from_string('name ends_with ski')
    predicate.predicateFormat.should == %Q(name ENDSWITH \"ski\")
  end

  it "defines .from_string('attribute contains value')" do
    predicate = Courier::Scope.from_string("name contains matt")
    predicate.predicateFormat.should == %Q(name CONTAINS \"matt\")
  end

  it "defines .from_string('attribute is_similar_to expression')" do
    predicate = Courier::Scope.from_string("name is_similar_to expression")
    predicate.predicateFormat.should == %Q(name LIKE \"expression\")
  end

  it "defines .from_string('attribute fits expression')" do
    predicate = Courier::Scope.from_string("name fits expression")
    predicate.predicateFormat.should == %Q(name MATCHES \"expression\")
  end

  it "defines .from_string('attribute is_any_of [val1,val2,val3])" do
    predicate = Courier::Scope.from_string('name is_any_of [val1,val2,val3]')
    predicate.predicateFormat.should == %Q(name IN {"val1", "val2", "val3"})
  end
end
