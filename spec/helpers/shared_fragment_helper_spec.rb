require 'spec_helper'

describe SharedFragmentHelper do
  before(:each) do
    @events = [stub_model(Event, :slug => 'foo'), stub_model(Event, :slug => 'bar')]
    helper.instance_variable_set(:@events, @events)
    Event.stub!(:lookup).and_return(@events)
    SharedFragmentWatcher.stub!(:render)
    SharedFragmentHelper.shared_fragment_render = true
  end

  after(:each) do
    SharedFragmentHelper.shared_fragment_render = false
  end

  shared_examples_for "all states" do
    it "should render shared fragments" do
      SharedFragmentHelper.should_receive(:render_theme_headers_to_files)
      SharedFragmentHelper.render_shared_fragments.should be_true
    end

    it "should render all events to files" do
      SharedFragmentHelper.should_receive(:render_theme_header_to_file).once.ordered.with(no_args)
      @events.each do |event|
        SharedFragmentHelper.should_receive(:render_theme_header_to_file).once.ordered.with(event)
      end

      SharedFragmentHelper.render_theme_headers_to_files
    end

    describe "render header to string" do
      it "should render for an event" do
        Event.stub!(:current).and_return(@events.first)
        event = @events.first
        res = SharedFragmentHelper.render_theme_header_to_string(event)
        res.should =~ /class="event active" id="event-#{event.slug}"/
      end

      it "should render for a given slug" do
        event = @events.first
        Event.stub!(:current).and_return(event)
        Event.should_receive(:lookup).with(event.slug).and_return(event)
        res = SharedFragmentHelper.render_theme_header_to_string(event.slug)
        res.should =~ /class="event active" id="event-#{event.slug}"/
      end

      it "should render for default event" do
        Event.stub!(:current).and_return(@events.first)
        res = SharedFragmentHelper.render_theme_header_to_string
        res.should =~ /class="event active" id="event-#{Event.current.slug}"/
      end

      it "should not die in a fire when no events are available" do
        Event.stub!(:current).and_return(nil)
        Event.stub!(:lookup).and_return([])
        res = SharedFragmentHelper.render_theme_header_to_string
        res.should =~ /class=(["'])events\1/
        res.should_not =~ /class=["']event\b/
      end
    end
  end

  describe "when rendering is enabled" do
    before(:each) do
      SharedFragmentHelper.stub!(:enabled => true)
    end

    it_should_behave_like "all states"

    it "should render theme header to a file" do
      path = "/tmp/ocw"
      SharedFragmentHelper.should_receive(:shared_fragment_path_for_header).and_return(path)

      fragment = "fragment"
      SharedFragmentHelper.should_receive(:render_theme_header_to_string).and_return(fragment)

      file_handle = mock 'file'
      File.should_receive(:open).with(path, "w+").and_yield(file_handle)
      file_handle.should_receive(:write).with(fragment)

      SharedFragmentHelper.render_theme_header_to_file.should be_true
    end
  end

  describe "when rendering is disabled" do
    before(:each) do
      SharedFragmentHelper.stub!(:enabled => false)
    end

    it_should_behave_like "all states"

    it "should not render theme header to a file" do
      SharedFragmentHelper.render_theme_header_to_file.should be_false
    end
  end
end
