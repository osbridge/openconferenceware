require 'spec_helper'

describe ApplicationHelper do
  describe "when using assigned events" do
    def assign_events(events)
      helper.instance_variable_set(:@events, events)
    end

    before do
      assign_events nil
    end

    describe "assigned_events" do
      it "should return assigned events" do
        events = [mock_model(Event), mock_model(Event)]
        assign_events events

        helper.assigned_events.should == events
      end

      it "should return empty array if no events are assigned" do
        helper.assigned_events.should == []
      end
    end

    describe "assigned_nonchild_events" do
      it "should return only nonchild events" do
        parent = mock_model(Event, :parent => nil, :parent_id => nil)
        child  = mock_model(Event, :parent => parent, :parent_id => parent.id)

        assign_events [parent, child]

        helper.assigned_nonchild_events.should == [parent]
      end
    end

    describe "assigned_nonchild_events_by_date" do
      it "should return only nonchild events sorted by date" do
        first  = mock_model(Event,
          :parent => nil,
          :parent_id => nil,
          :end_date => Time.parse('2001/1/1'))
        second = mock_model(Event,
          :parent => nil,
          :parent_id => nil,
          :end_date => Time.parse('2002/2/2'))
        child  = mock_model(Event,
          :parent => second,
          :parent_id => second.id,
          :end_date => Time.parse('2002/2/2'))

        assign_events [second, child, first]

        helper.assigned_nonchild_events_by_date.should == [first, second]
      end
    end
  end
end
