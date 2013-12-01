require 'spec_helper'

describe Room do
  before(:each) do
    @valid_attributes = {
      :name => "The Living Room",
      :event => stub_model(Event)
    }
  end

  it "should build a valid new instance given valid attributes" do
    build(:room, @valid_attributes).should be_valid
  end
end
