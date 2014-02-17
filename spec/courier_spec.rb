describe "The Courier Class" do
  behaves_like "A Core Data Spec"

  before do
    class Cup < Courier::Base; end
    class Plate < Courier::Base; end
  end

  it "defines a singleton reachable at .instance" do
    Courier::Courier.instance.class.should == Courier::Courier
    Courier::Courier.instance.should == Courier::Courier.instance
  end

  it "builds a schema and create a main context when .parcels=[m1,m2,etx] are set" do
    courier = Courier::Courier.instance
    courier.parcels = [Cup, Plate]
    courier.contexts[:main].class.should == CoreData::Context
  end
end
