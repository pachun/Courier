describe "Courier Inverse Relationship Resolutions" do
  before do
    Courier::nuke.everything.right.now
    Object.send(:remove_const, :Dealer) if Object.constants.include?(:Dealer)
    Object.send(:remove_const, :Car) if Object.constants.include?(:Car)

    class Dealer < Courier::Base
      has_many :cars, as: :used_cars, on_delete: :nullify, inverse_name: :used_car_dealership
      has_many :cars, as: :new_cars, on_delete: :nullify, inverse_name: :new_car_dealership
    end

    class Car < Courier::Base
      belongs_to :dealer, as: :used_car_dealership, on_delete: :nullify, inverse_name: :used_cars
      belongs_to :dealer, as: :new_car_dealership, on_delete: :nullify, inverse_name: :new_cars
    end
  end

  it "resolves inverse relationships correctly" do
    lambda do
      Courier::Courier.instance.parcels = [Dealer, Car]
    end.should.not.raise(Bacon::Error)
  end

  it "defines .add_to_[relationship_name](obj) correctly for multiple has_many relationships" do
    Courier::Courier.instance.parcels = [Dealer, Car]
    dealer = Dealer.create
    used_car = Car.create
    new_car = Car.create
    lambda do
      dealer.add_to_used_cars(used_car)
      dealer.add_to_new_cars(new_car)
    end.should.not.raise(Bacon::Error)
    dealer.used_cars.class.should == [].class
    dealer.new_cars.class.should == [].class
    used_car.used_car_dealership.should == dealer
    new_car.new_car_dealership.should == dealer
    dealer.used_cars.should.include(used_car)
    dealer.new_cars.should.include(new_car)
    dealer.used_cars.count.should == 1
    dealer.new_cars.count.should == 1
  end
end
