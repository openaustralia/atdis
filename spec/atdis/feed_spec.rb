require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Feed do
  let(:feed) { ATDIS::Feed.new("http://www.council.nsw.gov.au/atdis/1.0/applications.json") }
  let(:page) { double }

  it "should return all the applications" do
    ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json").and_return(page)
    feed.applications.should == page
  end

  describe "should restrict search by postcode" do
    it "single postcode" do
      ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000").and_return(page)
      feed.applications(:postcode => 2000).should == page
    end

    it "multiple postcodes in an array" do
      ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000,2001").and_return(page)
      feed.applications(:postcode => [2000,2001]).should == page
    end

    it "multiple postcodes as a string" do
      ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000,2001").and_return(page)
      feed.applications(:postcode => "2000,2001").should == page
    end
  end
end
