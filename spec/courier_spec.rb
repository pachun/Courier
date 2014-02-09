describe "The Courier Module" do
  before do
    class Child < CoreData::Model; end
    class Toy < CoreData::Model; end
  end

  it "saves core data models with .models=([m1,m2,..etc])" do
    Courier.models.should == []
    Courier.models = [Child, Toy]
    Courier.models.should == [Child, Toy]
  end
end
