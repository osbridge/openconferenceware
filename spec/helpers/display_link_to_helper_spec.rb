require 'spec_helper'
require 'hpricot'

describe DisplayLinkToHelper do
  def elem_for(*args)
    return Hpricot(helper.display_link_to(*args)).root
  end

  describe "when creating link" do
    it "should create link" do
      url = "http://foo.bar/"
      elem = elem_for(url)

      elem['href'].should == url
      elem.inner_html.should == url
    end

    it "should escape characters" do
      url = "<evil>&</evil>"
      elem = elem_for(url)

      elem.to_original_html.should =~ %r{<a href=\"&lt;evil&gt;&amp;&lt;/evil&gt;\"}
      elem.inner_html.should_not == url
      elem.inner_html.should == "&lt;evil&gt;&amp;&lt;/evil&gt;"
    end

    it "should truncate long URL" do
      url = "http://foo.bar/abcdefghijklmnopqrstuvwxyz"
      maxlength = 16
      elem = elem_for(url, :maxlength => maxlength)

      elem['href'].should == url
      elem.inner_html.should_not == url
      elem.inner_html.should == "http://foo.ba..."
      elem.inner_html.size.should == maxlength
    end

    it "should add norelfollow" do
      url = "http://foo.bar/"
      elem = elem_for(url)

      elem['rel'].should == "nofollow"
    end

    it "should not add norelfollow optionally" do
      url = "http://foo.bar/"
      elem = elem_for(url, :nofollow => false)

      elem['rel'].should be_blank
    end
  end
end
