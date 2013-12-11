require 'spec_helper'

describe ScheduleItem do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    ScheduleItem.create!(@valid_attributes)
  end
end
