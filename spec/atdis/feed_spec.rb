require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Feed do
  let(:feed) { ATDIS::Feed.new("http://www.council.nsw.gov.au/atdis/1.0/applications.json") }
  let(:page) { double }

  it "should return all the applications" do
    ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json").and_return(page)
    feed.applications.should == page
  end

  it "should restrict search by postcode" do
    ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000").and_return(page)
    feed.applications(:postcode => 2000).should == page
  end
end
