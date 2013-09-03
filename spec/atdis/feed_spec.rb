require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Feed do
  let (:base_url_string) { "http://www.council.nsw.gov.au" }
  let (:base_url) { URI.parse(base_url_string) }

  context "base_url passed as string" do
    let(:feed) { ATDIS::Feed.new(base_url_string) }

    describe "#base_url" do
      it { feed.base_url.should == base_url }
    end

    describe "#applications" do
      it do
        applications_results = double
        ATDIS::Page.should_receive(:read_url).with(URI.parse("http://www.council.nsw.gov.au/atdis/1.0/applications.json")).and_return(applications_results)
        feed.applications.should == applications_results
      end
    end
  end

  context "base_url passed as url" do
    let(:feed) { ATDIS::Feed.new(base_url) }

    describe "#base_url" do
      it { feed.base_url.should == base_url }
    end
  end
end
