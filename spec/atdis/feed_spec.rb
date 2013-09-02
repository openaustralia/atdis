require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Feed do
  let (:base_url_string) { "http://www.council.nsw.gov.au" }
  let (:base_url) { URI.parse(base_url_string) }

  context "base_url passed as string" do
    let(:applications) { ATDIS::Feed.new(base_url_string) }

    describe "#base_url" do
      it { applications.base_url.should == base_url }
    end

    describe "#all" do
      it do
        applications_results = double
        ATDIS::ApplicationsResults.should_receive(:read).with(ATDIS::SeparatedURL.new("http://www.council.nsw.gov.au/atdis/1.0/applications.json")).and_return(applications_results)
        applications.all.should == applications_results
      end
    end
  end

  context "base_url passed as url" do
    let(:applications) { ATDIS::Feed.new(base_url) }

    describe "#base_url" do
      it { applications.base_url.should == base_url }
    end
  end
end
