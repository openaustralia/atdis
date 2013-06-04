require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Applications do
  let (:base_url_string) { "http://www.council.nsw.gov.au" }
  let (:base_url) { URI.parse(base_url_string) }

  context "base_url passed as string" do
    let(:applications) { ATDIS::Applications.new(base_url_string) }

    describe "#base_url" do
      it { applications.base_url.should == base_url }
    end
  end

  context "base_url passed as url" do
    let(:applications) { ATDIS::Applications.new(base_url) }

    describe "#base_url" do
      it { applications.base_url.should == base_url }
    end
  end

  context "paging not supported by vendor" do
    let(:applications) { ATDIS::Applications.new(base_url_string) }

    it "should grab all the applications using json" do
      # Mock network response
      RestClient.should_receive(:get).with(URI.parse("http://www.council.nsw.gov.au/atdis/1.0/applications.json")).and_return(mock(:to_str => <<-EOF
{
  "response": [
    {
      "application": {
        "description": "application1"
      }     
    },
    {
      "application": {
        "description": "application2"
      }      
    }
  ]
}
      EOF
      ))
      application1 = mock("Application")
      application2 = mock("Application")
      ATDIS::Application.should_receive(:interpret).with(:description => "application1").and_return(application1)
      ATDIS::Application.should_receive(:interpret).with(:description => "application2").and_return(application2)

      a = applications.all
      a.results.should == [application1, application2]
      a.next.should be_nil
    end
  end
end
