require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Page do
  it ".attribute_names" do
    ATDIS::Page.attribute_names.should == ["results", "count", "previous_page_no", "next_page_no", "current_page_no",
      "no_results_per_page", "total_no_results", "total_no_pages"]
  end

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
          page.total_no_results = 2
          page.total_no_pages = 1
        end
        it { page.should be_valid }

        context "count is not consistent" do
          before :each do
            page.count = 1
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {:count => [ATDIS::ErrorMessage["is not the same as the number of applications returned", "6.5"]]}
          end
        end

        context "count is larger than number of results per page" do
          before :each do
            page.no_results_per_page = 1
            page.total_no_results = 1
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {:count => [ATDIS::ErrorMessage["should not be larger than the number of results per page", "6.5"]]}
          end
        end

        context "count is absent" do
          before :each do
            page.count = nil
          end

          it do
            page.should_not be_valid
            page.errors.messages.should == {:count => [ATDIS::ErrorMessage["should be present if pagination is being used", "6.5"]]}
          end
        end

        context "previous page number is pointing to a weird page number" do
          before :each do
            page.previous_page_no = 5
            page.current_page_no = 2
            page.total_no_results = 50
            page.total_no_pages = 2
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {:previous_page_no => [ATDIS::ErrorMessage["should be one less than current page number or null if first page", "6.5"]]}
            page.json_errors.should == [[{:pagination => {:previous => 5}}, [ATDIS::ErrorMessage["should be one less than current page number or null if first page", "6.5"]]]]
          end
        end

        context "previous page number if nil but not on first page" do
          before :each do
            page.current_page_no = 4
            page.next_page_no = 5
            page.previous_page_no = nil
            page.total_no_results = 240
            page.total_no_pages = 10
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {:previous_page_no => [ATDIS::ErrorMessage["can't be null if not on the first page", "6.5"]]}
          end
        end

        context "previous page number not nil but on first page" do
          before :each do
            page.current_page_no = 1
            page.next_page_no = 2
            page.previous_page_no = 0
            page.total_no_results = 240
            page.total_no_pages = 10
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {:previous_page_no => [ATDIS::ErrorMessage["should be null if on the first page", "6.5"]]}
          end
        end

        context "next page number is pointing to a weird page number" do
          before :each do
            page.next_page_no = 5
            page.total_no_results = 50
            page.total_no_pages = 2
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {:next_page_no => [ATDIS::ErrorMessage["should be one greater than current page number or null if last page", "6.5"]]}
          end          
        end

        context "next page number is nil but not on last page" do
          before :each do
            page.current_page_no = 4
            page.previous_page_no = 3
            page.next_page_no = nil
            page.total_no_results = 140
            page.total_no_pages = 6
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {:next_page_no => [ATDIS::ErrorMessage["can't be null if not on the last page", "6.5"]]}
          end
        end

        context "next page number is not nil but on last page" do
          before :each do
            page.previous_page_no = 3
            page.current_page_no = 4
            page.next_page_no = 5
            page.total_no_results = 100
            page.total_no_pages = 4
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {:next_page_no => [ATDIS::ErrorMessage["should be null if on the last page", "6.5"]]}
          end
        end

        context "current page is larger than the number of pages" do
          before :each do
            page.current_page_no = 2
            page.previous_page_no = 1
            page.next_page_no = 3
            page.total_no_pages = 1
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {:current_page_no => [ATDIS::ErrorMessage["is larger than the number of pages", "6.5"]]}
          end
        end

        context "current page is zero" do
          before :each do
            page.current_page_no = 0
            page.next_page_no = 1
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {:current_page_no => [ATDIS::ErrorMessage["can not be less than 1", "6.5"]]}
          end          
        end

        context "total_no_results is larger than would be expected" do
          before :each do
            page.current_page_no = 1
            page.next_page_no = 2
            page.no_results_per_page = 25
            page.total_no_pages = 4
            page.total_no_results = 101
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {:total_no_results => [ATDIS::ErrorMessage["is larger than can be retrieved through paging", "6.5"]]}
          end          
        end

        context "total no_results is less than would be expected" do
          before :each do
            page.current_page_no = 1
            page.next_page_no = 2
            page.no_results_per_page = 25
            page.total_no_pages = 4
            page.total_no_results = 75
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {:total_no_results => [ATDIS::ErrorMessage["could fit into a smaller number of pages", "6.5"]]}
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
        page.errors.messages.should == {:results => [ATDIS::ErrorMessage["is not valid", nil]]}
      end
    end

    context "two invalid applications no paging" do
      let(:a1) { double(:valid? => false, :json_errors => [[{:dat_id => "null"}, ["can not be empty"]]]) }
      let(:a2) { double(:valid? => false) }
      before :each do
        ATDIS::Application.should_receive(:interpret).with(:description => "application1").and_return(a1)
        ATDIS::Application.should_receive(:interpret).with(:description => "application2").and_return(a2)
      end
      let(:page) { ATDIS::Page.new(:results => [{:description => "application1"}, {:description => "application2"}]) }

      it do
        page.should_not be_valid
        page.errors.messages.should == {:results => [ATDIS::ErrorMessage["is not valid", nil]]}
      end

      it "the errors from the first errored application should be here" do
        page.should_not be_valid
        page.json_errors.should == [[{:response => {:dat_id => "null"}} , ["can not be empty"]]]
      end

    end
  end

  describe ".level_used?" do
    describe "level 1" do
      context "two applications" do
        before :each do
          ATDIS::Application.should_receive(:interpret).with(:description => "application1").and_return(double)
          ATDIS::Application.should_receive(:interpret).with(:description => "application2").and_return(double)
        end
        let(:page) { ATDIS::Page.new(:results => [{:description => "application1"}, {:description => "application2"}]) }

        it { page.level_used?(1).should be_true }
      end

      context "no L1 features used" do
        let(:page) { ATDIS::Page.new }
        it { page.level_used?(1).should be_false }
      end
    end

    describe "level 2" do
      context "two applications with only L1 features" do
        let(:a1) { double }
        let(:a2) { double }
        before :each do
          ATDIS::Application.should_receive(:interpret).with(:description => "application1").and_return(a1)
          ATDIS::Application.should_receive(:interpret).with(:description => "application2").and_return(a2)
        end
        let(:page) { ATDIS::Page.new(:results => [{:description => "application1"}, {:description => "application2"}]) }

        it do
          a1.should_receive(:level_used?).with(2).and_return(false)
          a2.should_receive(:level_used?).with(2).and_return(false)
          page.level_used?(2).should be_false
        end

        context "L2 feature used on Page" do
          before :each do
            page.count = 2
          end

          it { page.level_used?(2).should be_true }
        end
      end

      context "two applications with L2 features" do
        let(:a1) { double }
        let(:a2) { double }
        before :each do
          ATDIS::Application.should_receive(:interpret).with(:description => "application1").and_return(a1)
          ATDIS::Application.should_receive(:interpret).with(:description => "application2").and_return(a2)
        end
        let(:page) { ATDIS::Page.new(:results => [{:description => "application1"}, {:description => "application2"}]) }

        it "should ask the applications whether they have L2 features" do
          a1.should_receive(:level_used?).with(2).and_return(true)
          page.level_used?(2).should be_true
        end
      end
    end
  end

  context "paging supported by vendor" do
    context "read a from an invalid json string" do
      let(:page) { ATDIS::Page.read_json(<<-EOF
{
  "response": [
    {
      "application": {
        "description": "application2"
      }      
    }
  ],
}        
       EOF
        )}

      it do
        page.should_not be_valid
        page.errors.messages.has_key?(:json).should be_true
        page.errors.messages.count.should == 1
        # The error messages returned by the library are different for different Ruby versions
        ruby18_message = 'Invalid JSON: unexpected "}"'
        ruby19_message = "Invalid JSON: 784: unexpected token at '{\n  \"response\": [\n    {\n      \"application\": {\n        \"description\": \"application2\"\n      }      \n    }\n  ],\n}        \n'"
        ruby20_message = "Invalid JSON: 795: unexpected token at '{\n  \"response\": [\n    {\n      \"application\": {\n        \"description\": \"application2\"\n      }      \n    }\n  ],\n}        \n'"
        page.errors.messages[:json].count.should == 1
        message = page.errors.messages[:json].first
        (message == ruby18_message || message == ruby19_message || message == ruby20_message).should be_true
      end
    end

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
        expect { page.next }.to raise_error "Can't use next_url when loaded with read_json"
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

    it ".next_url" do
      applications_results.next_url.should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=3"
    end

    it ".next" do
      n = double("Page")
      applications_results
      ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=3").and_return(n)
      applications_results.next.should == n
    end
  end
end
