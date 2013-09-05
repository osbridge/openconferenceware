require 'spec_helper'

describe Proposal do
  fixtures :all

  context "when checking authorization for altering" do
    before(:each) do
      @proposal = proposals(:quentin_widgets)
    end

    it "should not allow anonymous" do
      @proposal.can_alter?(nil).should be_false
    end

    it "should not allow wrong mortal" do
      @proposal.can_alter?(users(:clio)).should be_false
    end

    it "should allow mortal owner" do
      @proposal.can_alter?(users(:quentin)).should be_true
    end

    it "should allow admin" do
      @proposal.can_alter?(users(:aaron)).should be_true
    end
  end

  context "when setting submitted_at date" do
    it "should set value on save" do
      proposal = proposals(:quentin_widgets)
      proposal.submitted_at = nil
      proposal.save!
      proposal.reload

      proposal.submitted_at.should_not be_nil
    end

    it "should set value to created_at date" do
      proposal = proposals(:quentin_widgets)
      proposal.submitted_at = nil
      proposal.save!
      proposal.reload

      proposal.submitted_at.should == proposal.created_at
    end
  end

  describe "when setting status" do
    before(:each) do
      @proposal = new_proposal
      @proposal.save!
    end

    it "should default to a state of 'proposed'" do
      @proposal.should be_proposed
    end

    it "should be possible to accept a proposed proposal" do
      @proposal.accept!
      @proposal.should be_accepted
    end

    it "should be possible to confirm a proposed proposal" do
      @proposal.accept_and_confirm!
      @proposal.should be_confirmed
    end

    it "should be possible to decline a proposed proposal" do
      @proposal.accept_and_decline!
      @proposal.should be_declined
    end

    it "should be possible to reject a proposed proposal" do
      @proposal.reject!
      @proposal.should be_rejected
    end

    it "should be possible to confirm an accepted proposal" do
      @proposal.status = 'accepted'
      @proposal.confirm!
      @proposal.should be_confirmed
    end
    
    it "should be possible to decline an accepted proposal" do
      @proposal.status = 'accepted'
      @proposal.decline!
      @proposal.should be_declined
    end

    it "should be possible to accept a rejected proposal" do
      @proposal.status = 'rejected'
      @proposal.accept!
      @proposal.should be_accepted
    end

    it "should be possible to reject an accepted proposal" do
      @proposal.status = 'accepted'
      @proposal.reject!
      @proposal.should be_rejected
    end

    it "should be possible to mark a proposed proposal as junk" do
      @proposal.mark_as_junk!
      @proposal.should be_junk
    end

    it "should be possible to cancel a confirmed proposal" do
      @proposal.status = 'confirmed'
      @proposal.cancel!
      @proposal.should be_cancelled
    end

    it "should be possible to waitlist a proposed proposal" do
      @proposal.waitlist!
      @proposal.should be_waitlisted
    end

    it "should be possible to waitlist an accepted proposal" do
      @proposal.status = 'accepted'
      @proposal.waitlist!
      @proposal.should be_waitlisted
    end

    it "should be possible to waitlist a rejected proposal" do
      @proposal.status = 'rejected'
      @proposal.waitlist!
      @proposal.should be_waitlisted
    end

    it "should be possible to accept a waitlisted proposal" do
      @proposal.status = 'waitlisted'
      @proposal.accept!
      @proposal.should be_accepted
    end

    it "should be possible to confirm a waitlisted proposal" do
      @proposal.status = 'waitlisted'
      @proposal.accept_and_confirm!
      @proposal.should be_confirmed
    end

    it "should be possible to decline a waitlisted proposal" do
      @proposal.status = 'waitlisted'
      @proposal.accept_and_decline!
      @proposal.should be_declined
    end

    it "should be possible to reject a waitlisted proposal" do
      @proposal.status = 'waitlisted'
      @proposal.reject!
      @proposal.should be_rejected
    end

    %w(accepted confirmed waitlisted rejected declined junk cancelled).each do |initial_status|
      it "should be posible to reset a #{initial_status} proposal back to proposed" do
        @proposal.status = initial_status
        @proposal.reset_status!
        @proposal.should be_proposed
      end
    end

    describe "through the transition accessor" do
      it "should be possible to call a valid event" do
        @proposal.should be_proposed
        @proposal.transition = 'accept'
        @proposal.should be_accepted
      end

      it "should not call invalid event methods" do
        @proposal.should_not_receive(:destroy!)
        @proposal.transition = 'destroy'
      end
    end
  end

  context "when getting comments" do
    before(:each) do
      @proposal = proposals(:quentin_widgets)
    end

    it "should return nothing if no comments" do
      @proposal.comments_text.blank?.should be_true
    end

    it "should return one comment" do
      comments = [
        mock(Comment, :email => "bubba@smith.com", :message => "Hi"),
      ]
      @proposal.should_receive(:comments).and_return(comments)

      @proposal.comments_text.should == "bubba@smith.com: Hi"
    end

    it "should return multiple comments" do
      comments = [
        mock(Comment, :email => "bubba@smith.com", :message => "Hi"),
        mock(Comment, :email => "billy.sue@smith.com", :message => "Yo"),
      ]
      @proposal.should_receive(:comments).and_return(comments)

      @proposal.comments_text.should ==
        "bubba@smith.com: Hi\nbilly.sue@smith.com: Yo"
    end
  end

  context "when getting profile" do
    before(:each) do
      @proposal = proposals(:quentin_widgets)
    end

    it "should return false if multiple_presenters is enabled" do
      SETTINGS.stub!(:have_multiple_presenters).and_return(true)
      @proposal.profile.should be_false
    end

    it "should return the user if user_profiles is enabled" do
      SETTINGS.stub!(:have_multiple_presenters).and_return(false)
      SETTINGS.stub!(:have_user_profiles).and_return(true)
      @proposal.profile.should == @proposal.user
    end

    it "should return itself if multiple_presenters and user_profiles are disabled" do
      SETTINGS.stub!(:have_multiple_presenters).and_return(false)
      SETTINGS.stub!(:have_user_profiles).and_return(false)
      @proposal.profile.should == @proposal
    end
  end

  describe "when adding or removing user", :shared => true do
    before(:each) do
      @user = stub_model(User)
      @users = mock_model(Array)
      @proposal = stub_model(Proposal)
      @proposal.should_receive(:users).any_number_of_times.and_return(@users)
    end
  end

  describe "when adding user" do
    it_should_behave_like "when adding or removing user"

    it "should add a user" do
      @users.should_receive(:include?).with(@user).and_return(false)
      @users.should_receive(:<<).with(@user).and_return(@user)

      @proposal.add_user(@user)
    end

    it "should not re-add an existing user" do
      @users.should_receive(:include?).with(@user).and_return(true)
      @users.should_not_receive(:<<)

      @proposal.add_user(@user)
    end
  end

  describe "when removing user" do
    it_should_behave_like "when adding or removing user"

    it "should remove a user" do
      @users.should_receive(:include?).with(@user).and_return(true)
      @users.should_receive(:delete).with(@user).and_return(@user)

      @proposal.remove_user(@user)
    end

    it "should not remove a non-existent user" do
      @users.should_receive(:include?).with(@user).and_return(false)
      @users.should_not_receive(:delete)

      @proposal.remove_user(@user)
    end
  end

  describe "with rooms" do
    before :each do
      @proposal = Proposal.new
    end

    it "should be able to assign a room to an proposal" do
      room = stub_model(Room)
      @proposal.room = room
      @proposal.room.should==room
    end
  end

  describe "to_icalendar" do
    def assert_calendar_match(item, component, url_helper=nil)
      component.should_not be_nil

      # This is hacky, but necessary because vPim doesn't actually parse
      # time zone information out of iCalendar files.
      #
      # The files are output with the correct time zone, but seem to be
      # parsed in the computer's local time, regardless of the Rails
      # time zone setting.
      dtstart = Time.parse(component.dtstart.strftime('%Y-%m-%d %H:%M:%S UTC'))
      dtstart.to_i.should == item.start_time.to_i
      if item.duration
        dtend = Time.parse(component.dtend.strftime('%Y-%m-%d %H:%M:%S UTC'))
        dtend.to_i.should == item.end_time.to_i
      else
        component.dtend.should be_nil
      end
      component.summary.should == item.title
      component.description.should == (item.respond_to?(:users) ?
        "#{item.users.map(&:fullname).join(', ')}: #{item.excerpt}" :
        item.excerpt)
      component.url.should == url_helper.call(item) if url_helper
    end

    it "should export proposals to iCalendar" do
      mysql_record = proposals(:mysql_session)
      postgresql_record = proposals(:postgresql_session)
      items = [ mysql_record, postgresql_record ]
      title = "MyTitle"
      url_helper = lambda {|item| "http://foo.bar/#{item.id}"}

      data = Proposal.to_icalendar(items, :title => title, :url_helper => url_helper)

      calendar = Vpim::Icalendar.decode(data).first
      components = Array(calendar)
      components.size.should == 2
      assert_calendar_match(mysql_record, components.find{|t| t.summary == mysql_record.title}, url_helper)
      assert_calendar_match(postgresql_record, components.find{|t| t.summary == postgresql_record.title}, url_helper)
    end

    it "should skip items without a start time" do
      event = Factory :populated_event
      item = Factory :schedule_item, :start_time => nil, :duration => nil

      data = Proposal.to_icalendar([item])
      calendar = Vpim::Icalendar.decode(data).first
      components = Array(calendar)
      components.size.should == 0
    end

    it "should not raise exceptions if nil duration" do
      event = Factory :populated_event
      item = Factory :schedule_item, :duration => nil

      data = Proposal.to_icalendar([item])
      calendar = Vpim::Icalendar.decode(data).first
      components = Array(calendar)
      components.size.should == 1
      component = components.first
      assert_calendar_match(item, component)
    end
  end

  describe "session_notes_url" do
    before do
      @proposal = proposals(:clio_chupacabras)
    end

    it "should be nil if no session_notes_wiki_url_format is defined" do
      SETTINGS.stub!(:session_notes_wiki_url_format => nil)

      @proposal.session_notes_url.should be_nil
    end

    describe "with wiki" do
      before :each do
        SETTINGS.stub!(
          :session_notes_wiki_url_format => '%1$s%2$s/wiki/',
          :public_url => 'http://mysite.com/'
        )
      end

      it "should interpolate content if session_notes_wiki_url_format is defined" do
        @proposal.session_notes_url.should == "http://mysite.com/closed/wiki/Chupacabras_and_you"
      end

      it "should replace slashes with dashes" do
        @proposal.title = "CouchApp Evently Guided Hack w/ CouchDB"
        @proposal.session_notes_url.should == "http://mysite.com/closed/wiki/CouchApp_Evently_Guided_Hack_w-_CouchDB"
      end
    end
  end

  describe "when sorting" do
    before(:each) do
      @shonen   = stub_model(Track, :title => "Shonen")
      @bishoujo = stub_model(Track, :title => "Bishoujo")
      @tracks = [@shonen, @bishoujo]

      @naruto = stub_model(Proposal, 
        :title => "Naruto", 
        :track => @shonen, 
        :status => "proposed",
        :submitted_at => Time.parse('2009/12/09 01:00'),
        :start_time => Time.parse('2009/12/10 05:00'))
      @bleach = stub_model(Proposal,
        :title => "Bleach", 
        :track => @shonen, 
        :status => "confirmed",
        :submitted_at => Time.parse('2009/12/09 02:00'),
        :start_time => Time.parse('2009/12/10 04:00')) 
      @sera_mun = stub_model(Proposal,
        :title => "Bishoujo Senshi Sera Mun", 
        :track => @bishoujo, 
        :status => "confirmed",
        :submitted_at => Time.parse('2009/12/09 04:00'),
        :start_time => Time.parse('2009/12/10 01:00')) 
      @kadocapta_sakura = stub_model(Proposal,
        :title => "Kadocapta Sakura", 
        :track => @bishoujo, 
        :status => "accepted",
        :submitted_at => Time.parse('2009/12/09 03:00'),
        :start_time => Time.parse('2009/12/10 02:00'))
      @kino = stub_model(Proposal,
        :title => "Kino no Tabi", 
        :track => nil, 
        :status => "accepted",
        :submitted_at => Time.parse('2009/12/09 06:00'),
        :start_time => Time.parse('2009/12/10 06:00'))
      @proposals = [@kadocapta_sakura, @bleach, @kino, @naruto, @sera_mun]
    end

    it "should sort by title" do
      Proposal.sort(@proposals, :title).should == [@sera_mun, @bleach, @kadocapta_sakura, @kino, @naruto]
    end

    it "should sort by title descending" do
      Proposal.sort(@proposals, :title, false).should == [@naruto, @kino, @kadocapta_sakura, @bleach, @sera_mun]
    end

    it "should sort by track" do
      Proposal.sort(@proposals, :track).should == [@sera_mun, @kadocapta_sakura, @bleach, @naruto, @kino]
    end

    it "should sort by status" do
      Proposal.sort(@proposals, :status).should == [@kadocapta_sakura, @kino, @sera_mun, @bleach, @naruto]
    end

    it "should sort by submitted date" do
      Proposal.sort(@proposals, :submitted_at).should == [@naruto, @bleach, @kadocapta_sakura, @sera_mun, @kino]
    end

    it "should default to sorting by submitted date if given unknown sorting" do
      Proposal.sort(@proposals, :submitted_at).should == [@naruto, @bleach, @kadocapta_sakura, @sera_mun, @kino]
    end
  end

  describe "when retreiving slug" do
    it "should return a slug composed of the organization and event slugs plus the proposal identifier" do
      proposal = proposals(:clio_chupacabras)

      proposal.slug.should == "#{SETTINGS.organization_slug}#{proposal.event.slug}-%04d" % proposal.id
    end
  end

  describe "is a proposal related to an event?" do
    it "should be related to its own event" do
      event = Factory :populated_event
      proposal = proposal_for_event(event)

      proposal.related_to_event?(proposal.event).should be_true
    end

    it "should be related to its own event's parent" do
      parent = Factory :populated_event
      event = Factory :populated_event, :parent => parent
      proposal = proposal_for_event(event)

      proposal.related_to_event?(event).should be_true
    end

    it "should be related to its own event's parent's children" do
      event = Factory :populated_event
      child = Factory :populated_event, :parent => event
      proposal = proposal_for_event(event)

      proposal.related_to_event?(event).should be_true
    end

    it "should not be related to an unrelated event" do
      event = Factory :populated_event
      proposal = proposal_for_event(event)
      unrelated = Factory :populated_event

      proposal.related_to_event?(unrelated).should be_false
    end
  end

  describe "traversal" do
    before(:each) do
      @event = Factory :populated_event
      @event.proposals.destroy_all
      @proposal1 = proposal_for_event(@event)
      @proposal2 = proposal_for_event(@event)
    end

    context "when finding next proposal" do
      it "should return the next proposal when it exists" do
        @proposal1.next_proposal.should == @proposal2
      end

      it "should return nil when it's the last" do
        @proposal2.next_proposal.should be_nil
      end
    end

    context "when finding previous proposal" do
      it "should return the previous proposal when it exists" do
        @proposal2.previous_proposal.should == @proposal1
      end

      it "should return nil when it's the first" do
        @proposal1.previous_proposal.should be_nil
      end
    end
  end

  context "when notifying accepted speakers" do
    before(:each) do
      @proposal = proposals(:quentin_widgets)
    end

    it "should not notify unaccepted proposal speakers" do
      emailed, already = @proposal.notify_accepted_speakers
      emailed.should be_nil
      already.should be_nil
      @proposal.notified_at.should be_nil
    end

    it "should not notify already-notified proposal speakers" do
      @proposal.accept!
      @proposal.notified_at = Time.now
      emailed, already = @proposal.notify_accepted_speakers
      emailed.should be_nil
      already.should == @proposal.mailto_emails
    end

    it "should notify accepted proposal speakers" do
      @proposal.accept!
      SpeakerMailer.stub(:deliver_speaker_accepted_email).and_return(true)
      emailed, already = @proposal.notify_accepted_speakers
      emailed.should == @proposal.mailto_emails
      already.should be_nil
      @proposal.notified_at.should_not be_nil
    end
  end

  context "when notifying rejected speakers" do
    before(:each) do
      @proposal = proposals(:quentin_widgets)
    end

    it "should not notify unrejected proposal speakers" do
      emailed, already = @proposal.notify_rejected_speakers
      emailed.should be_nil
      already.should be_nil
      @proposal.notified_at.should be_nil
    end

    it "should not notify already-notified proposal speakers" do
      @proposal.reject!
      @proposal.notified_at = Time.now
      emailed, already = @proposal.notify_rejected_speakers
      emailed.should be_nil
      already.should == @proposal.mailto_emails
    end

    it "should notify rejected proposal speakers" do
      @proposal.reject!
      SpeakerMailer.stub(:deliver_speaker_rejected_email).and_return(true)
      emailed, already = @proposal.notify_rejected_speakers
      emailed.should == @proposal.mailto_emails
      already.should be_nil
      @proposal.notified_at.should_not be_nil
    end
  end


private

  def new_proposal(attr = {})
    valid_attr = {
      :event => mock_model(Event),
      :track => mock_model(Track),
      :session_type => mock_model(SessionType),
      :title => "New Proposal",
      :description => "Valid Description",
      :excerpt => "Valid Excerpt",
      :speaking_experience => "Valid Speaking Experience",
      :audience_level => "a"
    }
    Proposal.new(valid_attr.merge(attr))
  end
end
