describe Snippet do

  it "should find the content for the slug" do
    snippet = Snippet.make('fireplace', 'the metal box', 'things on fire')

    Snippet.content_for('fireplace').should == 'things on fire'
  end
end
