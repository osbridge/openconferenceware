require "spec_helper"
describe EmailthingNotifier do
  before(:each) do
    EmailthingNotifier.stub!(:start_processor_if_not_running)
  end

  it "should have a queue" do
    EmailthingNotifier.queue.should_not be_nil
  end

  it "should have a class method to tell that a link was clicked" do
    EmailthingNotifier.link_clicked("myid")
    EmailthingNotifier.queue.length.should == 1
  end
  it "should attempt to start the processor if it isn't running" do
    EmailthingNotifier.should_receive(:start_processor_if_not_running)
    EmailthingNotifier.link_clicked("myid")
  end

  it "should make an http request to emailthing with the et_id" do
    Net::HTTP.should_receive(:get).with(URI.parse("http://ping.emailthing.net/l/my_et_id"))
    EmailthingNotifier.process_et_id("my_et_id")
  end

end