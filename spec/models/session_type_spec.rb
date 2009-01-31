require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SessionType do
  fixtures :all

  before(:each) do
    @valid_attributes = {
      :title => "value for title",
      :description => "value for description",
      :event => events(:open)
    }
  end

  it "should create a new instance given valid attributes" do
    SessionType.create!(@valid_attributes)
  end
end
