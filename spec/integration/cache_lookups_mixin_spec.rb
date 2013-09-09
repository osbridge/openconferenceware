require 'spec_helper'

describe CacheLookupsMixin do
  before :each do
    Event.destroy_all if Event.count > 0
    User.destroy_all  if User.count  > 0
  end

  describe 'when enabled' do
    describe 'and environment defaults to performing caching' do
      shared_examples_for 'overrides' do
        it 'should cache lookups if forced to' do
          ENV.should_receive(:[]).with('CACHELOOKUPS').and_return('1')
          Event.cache_lookups?.should == true
        end

        it 'should not cache lookups if forced not to' do
          ENV.should_receive(:[]).with('CACHELOOKUPS').and_return('0')
          Event.cache_lookups?.should == false
        end
      end

      before do
        Rails.configuration.action_controller.stub(:perform_caching => true)
      end

      it_should_behave_like 'overrides'

      it 'should cache lookups by default' do
        Event.cache_lookups?.should == true
      end

    end

    describe 'and environment defaults to not performing caching' do
      before do
        Rails.configuration.action_controller.stub(:perform_caching => false)
      end

      it_should_behave_like 'overrides'

      it 'should not cache lookups by default' do
        Event.cache_lookups?.should == false
      end
    end
  end

  describe 'queries' do
    before :each do
      Event.stub(:cache_lookups? => true)
      CacheWatcher.expire

      @event1 = Factory :event
      @event2 = Factory :event

      @events = [@event1, @event2]
      @event  = @event1

      CacheWatcher.expire
    end

    describe 'for single records' do
      it 'should write to cache' do
        Event.should_receive(:query_all).and_return(@events)

        Event.lookup(@event.slug).should == @event
      end

      it 'should read from cache' do
        Event.lookup(@event.slug).should == @event
        Event.should_not_receive(:query_all)

        Event.lookup(@event.slug).should == @event
      end
    end

    describe 'for all records' do
      it 'should write to cache' do
        Event.should_receive(:query_all).and_return(@events)

        Event.lookup.should == @events
      end

      it 'should read from cache' do
        Event.lookup.should == @events
        Event.should_not_receive(:query_all)

        Event.lookup.should == @events
      end
    end

    describe 'current event' do
      before do
        @event = Factory :event
      end

      describe 'when caching' do
        it 'should fetch from cache' do
          Event.should_receive(:cache_lookups?).and_return(true)
          Event.should_receive(:fetch_object).with('event_current').and_return(@event)

          Event.current.should == @event
        end
      end

      describe 'when not caching' do
        it 'should not fetch from cache' do
          Event.should_receive(:cache_lookups?).and_return(false)
          Event.should_receive(:current_by_settings).and_return(@event)

          Event.current.should == @event
        end
      end
    end
  end

  describe 'silo name' do
    it 'should be derived from class name' do
      Event.lookup_silo_name.should == 'Event_dict'
    end
  end
end
