require 'spec_helper'

describe "/selector_votes/index.html.erb" do
  include SelectorVotesHelper

  before(:each) do
    assigns[:selector_votes] = [
      stub_model(SelectorVote),
      stub_model(SelectorVote)
    ]
  end

  it "renders a list of selector_votes" do
    render
  end
end
