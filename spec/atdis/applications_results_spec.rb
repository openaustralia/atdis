require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::ApplicationsResults do
  context "paging not supported by vendor" do
    before :each do
      # Mock network response
      RestClient.should_receive(:get).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json").and_return(mock(:to_str => <<-EOF
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
    end

    let(:applications_results) { ATDIS::ApplicationsResults.new("http://www.council.nsw.gov.au/atdis/1.0/applications.json") }

    it ".results" do
      application1 = mock("Application")
      application2 = mock("Application")
      ATDIS::Application.should_receive(:interpret).with(:description => "application1").and_return(application1)
      ATDIS::Application.should_receive(:interpret).with(:description => "application2").and_return(application2)

      applications_results.results.should == [application1, application2]
    end

    it ".next" do
      applications_results.next.should be_nil
    end
  end

  context "paging supported by vendor" do
    it "should use the page in determining the url" do
      RestClient.should_receive(:get).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2").and_return(mock(:to_str => nil))
      applications_results = ATDIS::ApplicationsResults.new("http://www.council.nsw.gov.au/atdis/1.0/applications.json", :page => 2)
    end
  end
end
