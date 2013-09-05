require 'spec_helper'

describe Room do
  before(:each) do
    @valid_attributes = {
      :name => "The Living Room",
      :event => stub_model(Event)
    }
  end

  it "should create a new instance given valid attributes" do
    Room.create!(@valid_attributes)
  end
end
