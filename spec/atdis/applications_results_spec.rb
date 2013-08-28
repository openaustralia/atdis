require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::ApplicationsResults do
  context "paging not supported by vendor" do
    before :each do
      # Mock network response
      RestClient.should_receive(:get).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json").and_return(double(:to_str => <<-EOF
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

    let(:applications_results) { ATDIS::ApplicationsResults.read(ATDIS::SeparatedURL.new("http://www.council.nsw.gov.au/atdis/1.0/applications.json")) }

    it ".results" do
      application1 = double("Application")
      application2 = double("Application")
      ATDIS::Application.should_receive(:interpret).with(:description => "application1").and_return(application1)
      ATDIS::Application.should_receive(:interpret).with(:description => "application2").and_return(application2)

      applications_results.results.should == [application1, application2]
    end

    it ".next" do
      applications_results.next.should be_nil
    end

    it ".previous_page_no" do
      applications_results.previous_page_no.should be_nil
    end

    it ".next_page_no" do
      applications_results.next_page_no.should be_nil
    end

    it ".current_page_no" do
      applications_results.current_page_no.should be_nil
    end

    it ".no_results_per_page" do
      applications_results.no_results_per_page.should be_nil
    end

    it ".total_no_results" do
      applications_results.total_no_results.should be_nil
    end

    it ".total_no_pages" do
      applications_results.total_no_pages.should be_nil
    end
  end

  context "paging supported by vendor" do
    before :each do
      RestClient.should_receive(:get).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2").and_return(double(:to_str => <<-EOF
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
  ],
  "count": 2,
  "pagination": {
    "previous": 1,
    "next": 3,
    "current": 2,
    "per_page": 2,
    "count": 50,
    "pages": 25
  }
}        
      EOF
      ))
    end

    let(:applications_results) { ATDIS::ApplicationsResults.read(ATDIS::SeparatedURL.new("http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2")) }

    it ".previous_page_no" do
      applications_results.previous_page_no.should == 1
    end

    it ".next_page_no" do
      applications_results.next_page_no.should == 3
    end

    it ".current_page_no" do
      applications_results.current_page_no.should == 2
    end

    it ".no_results_per_page" do
      applications_results.no_results_per_page.should == 2
    end

    it ".total_no_results" do
      applications_results.total_no_results.should == 50
    end

    it ".total_no_pages" do
      applications_results.total_no_pages.should == 25
    end

    it ".next" do
      n = double("ApplicationsResults")
      applications_results
      ATDIS::ApplicationsResults.should_receive(:read).with(ATDIS::SeparatedURL.new("http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=3")).and_return(n)
      applications_results.next.should == n
    end
  end
end
