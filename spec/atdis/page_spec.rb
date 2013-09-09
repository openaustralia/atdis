require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Page do
  describe "validations" do
    context "two valid applications no paging" do
      before :each do
        ATDIS::Application.should_receive(:interpret).with(:description => "application1").and_return(double(:valid? => true))
        ATDIS::Application.should_receive(:interpret).with(:description => "application2").and_return(double(:valid? => true))
      end
      let(:page) { ATDIS::Page.new(:results => [{:description => "application1"}, {:description => "application2"}]) }

      it {page.should be_valid}

      context "with pagination" do
        before :each do
          page.count = 2
          page.no_results_per_page = 25
          page.current_page_no = 1
          page.total_no_results = 100
          page.total_no_pages = 1
        end
        it { page.should be_valid }

        context "count is not consistent" do
          before :each do
            page.count = 1
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {:count => ["is not the same as the number of applications returned"]}
          end
        end

        context "count is absent" do
          before :each do
            page.count = nil
          end

          it do
            page.should_not be_valid
            page.errors.messages.should == {:count => ["should be present if pagination is being used"]}
          end
        end
      end
    end

    context "one valid application out of two no paging" do
      before :each do
        ATDIS::Application.should_receive(:interpret).with(:description => "application1").and_return(double(:valid? => true))
        ATDIS::Application.should_receive(:interpret).with(:description => "application2").and_return(double(:valid? => false))
      end
      let(:page) { ATDIS::Page.new(:results => [{:description => "application1"}, {:description => "application2"}]) }

      it do
        page.should_not be_valid
        page.errors.messages.should == {:results => ["is not valid"]}
      end
    end

    context "two invalid applications no paging" do
      before :each do
        ATDIS::Application.should_receive(:interpret).with(:description => "application1").and_return(double(:valid? => false))
        ATDIS::Application.should_receive(:interpret).with(:description => "application2").and_return(double(:valid? => false))
      end
      let(:page) { ATDIS::Page.new(:results => [{:description => "application1"}, {:description => "application2"}]) }

      it do
        page.should_not be_valid
        page.errors.messages.should == {:results => ["is not valid"]}
      end
    end
  end

  context "paging supported by vendor" do
    context "read from a json string" do
      let(:page) { ATDIS::Page.read_json(<<-EOF
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
        )}
      it ".results" do
        application1 = double("Application")
        application2 = double("Application")
        ATDIS::Application.should_receive(:interpret).with(:application => {:description => "application1"}).and_return(application1)
        ATDIS::Application.should_receive(:interpret).with(:application => {:description => "application2"}).and_return(application2)

        page.results.should == [application1, application2]
      end

      it ".next" do
        expect { page.next }.to raise_error "Can't use next when loaded with read_json"
      end
    end

    context "read from a url" do
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

      let(:applications_results) { ATDIS::Page.read_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json") }

      it ".results" do
        application1 = double("Application")
        application2 = double("Application")
        ATDIS::Application.should_receive(:interpret).with(:application => {:description => "application1"}).and_return(application1)
        ATDIS::Application.should_receive(:interpret).with(:application => {:description => "application2"}).and_return(application2)

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

    let(:applications_results) { ATDIS::Page.read_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2") }

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
      n = double("Page")
      applications_results
      ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=3").and_return(n)
      applications_results.next.should == n
    end
  end
end
