require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Feed do
  let(:feed) { ATDIS::Feed.new("http://www.council.nsw.gov.au/atdis/1.0/applications.json") }

  describe "#applications" do
    it do
      applications_results = double
      ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json").and_return(applications_results)
      feed.applications.should == applications_results
    end
  end
end
