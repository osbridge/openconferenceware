require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/proposals/show.html.erb" do
  before do
    @controller.stub!('can_edit?').and_return(false)
  end
  
  before :each do
    @users = []
    @users.stub!(:by_name).and_return([])
    
    @proposal = stub_model(Proposal, :status => "proposed", :users => @users)
    @event = stub_model(Event, :id => 1, :title => "Event 1", :proposal_status_published => false);
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
      response.should_not have_tag("div.proposal-status #{status}")
    end
  end
  
  it "should show the proposal status for a confirmed proposal if statuses are published" do
    @event.proposal_status_published = true
    @proposal.status = 'confirmed'
    
    assigns[:event]  = @event
    assigns[:proposal] = @proposal
    assigns[:kind] = :proposal
    
    render "/proposals/show.html.erb"
    response.should have_tag("div.proposal-status")
  end
  
  %w[accepted rejected junk].each do |status|
    it "should should not show the status for #{status} proposals even if statuses are published" do
      @event.proposal_status_published = true
      @proposal.status = status
      
      assigns[:event]  = @event
      assigns[:proposal] = @proposal
      assigns[:kind] = :proposal
    
      render "/proposals/show.html.erb"
      response.should_not have_tag("div.proposal-status #{status}")
    end
  end
end

