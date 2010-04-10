require File.dirname(__FILE__) + '/../spec_helper'

describe SharedFragmentHelper do
  before do
    events = [mock_model(Event), mock_model(Event)]
    helper.instance_variable_set(:@events, events)
  end

  describe "with rendering" do
    before do
      SharedFragmentHelper.stub!(:enabled => true)
    end
  end

  describe "without rendering" do
    before do
      SharedFragmentHelper.stub!(:enabled => false)
    end
  end
end
