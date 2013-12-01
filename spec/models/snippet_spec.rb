require 'spec_helper'

describe Snippet do

  it "should find the content for the slug" do
    snippet = create(:snippet,  slug: 'fireplace',
                                description: 'the metal box',
                                content: 'things on fire')

    Snippet.content_for('fireplace').should == 'things on fire'
    Snippet['fireplace'].should == 'things on fire'
  end
end
