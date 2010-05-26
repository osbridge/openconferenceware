require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/proposals/show.html.erb" do
  before do
    @controller.stub!('can_edit?').and_return(false)
  end
  
  before :each do
    @user = Factory :user
    @event = Factory :populated_event, :proposal_status_published => false
    @proposal = proposal_for_event(@event, :users => [@user])

    @controller.stub!(:schedule_visible? => true)
  end
  
  %w[accepted confirmed rejected junk].each do |status|
    it "should not show the status for #{status} proposals if statuses are not published" do
      @event.proposal_status_published = false
      @proposal.status = status
      
      assigns[:event]  = @event
      assigns[:proposal] = @proposal
      assigns[:kind] = :proposal
    
      render "/proposals/show.html.erb"
      response.should_not have_tag(".proposal-status #{status}")
    end
  end
  
  %w[accepted rejected junk].each do |status|
    it "should should not show the status for #{status} proposals even if statuses are published" do
      @event.proposal_status_published = true
      @proposal.status = status
      
      assigns[:event]  = @event
      assigns[:proposal] = @proposal
      assigns[:kind] = :proposal
    
      render "/proposals/show.html.erb"
      response.should_not have_tag(".proposal-status #{status}")
    end
  end

  describe "with confirmed proposal for event that publishes status" do
    before :each do
      @event.proposal_status_published = true
      @proposal.status = 'confirmed'
      @proposal.start_time = nil
      @proposal.room = nil

      assigns[:event]  = @event
      assigns[:proposal] = @proposal
      assigns[:kind] = :proposal
    end

    it "should show the proposal status for a confirmed proposal" do
      render "/proposals/show.html.erb"
      response.should have_tag(".proposal-status")
      response.should_not have_tag(".proposal-scheduling")
      response.should_not have_tag(".proposal-room")
    end

    it "should show session time if set" do
      @proposal.start_time = Time.now

      render "/proposals/show.html.erb"
      response.should have_tag(".proposal-scheduling")
      response.should_not have_tag(".proposal-room")
    end

    it "should show session time and location if both set" do
      @proposal.start_time = Time.now
      @proposal.room = @event.rooms.first

      render "/proposals/show.html.erb"
      response.should have_tag(".proposal-scheduling")
      response.should have_tag(".proposal-room")
    end
  end
end

