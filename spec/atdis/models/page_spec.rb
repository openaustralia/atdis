require "spec_helper"

describe ATDIS::Models::Page do
  it ".attribute_names" do
    ATDIS::Models::Page.attribute_names.should == ["response", "count", "pagination"]
  end

  describe "validations" do
    context "results block that is a hash" do
      before :each do
        ATDIS::Models::Response.should_receive(:interpret).with(description: "application1").and_return(double(valid?: true))
      end
      let(:page) { ATDIS::Models::Page.new(response: {description: "application1"}) }

      it do
        page.should_not be_valid
        page.errors.messages.should == {response: [ATDIS::ErrorMessage["should be an array", "6.4"]]}
      end
    end

    context "two valid applications no paging" do
      before :each do
        ATDIS::Models::Response.should_receive(:interpret).with(description: "application1").and_return(double(valid?: true))
        ATDIS::Models::Response.should_receive(:interpret).with(description: "application2").and_return(double(valid?: true))
      end
      let(:page) { ATDIS::Models::Page.new(response: [{description: "application1"}, {description: "application2"}]) }

      it {page.should be_valid}

      context "with pagination" do
        before :each do
          page.count = 2
          page.pagination = ATDIS::Models::Pagination.new(per_page: 25, current: 1, count: 2, pages: 1)
        end
        it { page.should be_valid }

        context "count is not consistent" do
          before :each do
            page.count = 1
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {count: [ATDIS::ErrorMessage["is not the same as the number of applications returned", "6.4"]]}
          end
        end

        context "count is larger than number of results per page" do
          before :each do
            page.pagination.per_page = 1
            page.pagination.count = 1
          end
          it do
            page.should_not be_valid
            page.errors.messages.should == {count: [ATDIS::ErrorMessage["should not be larger than the number of results per page", "6.4"]]}
          end
        end

        context "count is absent" do
          before :each do
            page.count = nil
          end

          it do
            page.should_not be_valid
            page.errors.messages.should == {count: [ATDIS::ErrorMessage["should be present if pagination is being used", "6.4"]]}
          end
        end

        context "pagination not valid" do
          before :each do
            page.pagination.should_receive(:valid?).and_return(false)
          end

          it do
            page.should_not be_valid
            page.errors.messages.should == {pagination: [ATDIS::ErrorMessage["is not valid (see further errors for details)", nil]]}
          end
        end
      end
    end

    context "one valid application out of two no paging" do
      before :each do
        ATDIS::Models::Response.should_receive(:interpret).with(description: "application1").and_return(double(valid?: true))
        ATDIS::Models::Response.should_receive(:interpret).with(description: "application2").and_return(double(valid?: false))
      end
      let(:page) { ATDIS::Models::Page.new(response: [{description: "application1"}, {description: "application2"}]) }

      it do
        page.should_not be_valid
        page.errors.messages.should == {response: [ATDIS::ErrorMessage["is not valid (see further errors for details)", nil]]}
      end
    end

    context "two invalid applications no paging" do
      let(:a1) { double(valid?: false, json_errors: [[{dat_id: "null"}, ["can not be empty"]]]) }
      let(:a2) { double(valid?: false) }
      before :each do
        ATDIS::Models::Response.should_receive(:interpret).with(description: "application1").and_return(a1)
        ATDIS::Models::Response.should_receive(:interpret).with(description: "application2").and_return(a2)
      end
      let(:page) { ATDIS::Models::Page.new(response: [{description: "application1"}, {description: "application2"}]) }

      it do
        page.should_not be_valid
        page.errors.messages.should == {response: [ATDIS::ErrorMessage["is not valid (see further errors for details)", nil]]}
      end

      it "the errors from the first errored application should be here" do
        page.should_not be_valid
        page.json_errors.should == [[{response: [{description: "application1"}, {description: "application2"}]}, [ATDIS::ErrorMessage["response is not valid (see further errors for details)"]]], [{response: [{dat_id: "null"}]} , ["can not be empty"]]]
      end

    end
  end

  context "paging supported by vendor" do
    context "read a from an invalid json string" do
      let(:page) { ATDIS::Models::Page.read_json(<<-EOF
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
        ruby19_message = ATDIS::ErrorMessage["Invalid JSON: 784: unexpected token at '{\n  \"response\": [\n    {\n      \"application\": {\n        \"description\": \"application2\"\n      }\n    }\n  ],\n}\n'", nil]
        ruby20_message = ATDIS::ErrorMessage["Invalid JSON: 795: unexpected token at '{\n  \"response\": [\n    {\n      \"application\": {\n        \"description\": \"application2\"\n      }\n    }\n  ],\n}\n'", nil]
        page.errors.messages[:json].count.should == 1
        message = page.errors.messages[:json].first
        (message == ruby19_message || message == ruby20_message).should be_true
      end
    end

    context "read from a json string" do
      let(:page) { ATDIS::Models::Page.read_json(<<-EOF
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
        ATDIS::Models::Response.should_receive(:interpret).with(application: {description: "application1"}).and_return(application1)
        ATDIS::Models::Response.should_receive(:interpret).with(application: {description: "application2"}).and_return(application2)

        page.response.should == [application1, application2]
      end

      it ".next_page" do
        expect { page.next_page }.to raise_error "Can't use next_url when loaded with read_json"
      end
    end

    context "read from a url" do
      before :each do
        # Mock network response
        RestClient.should_receive(:get).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json").and_return(double(to_str: <<-EOF
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

      let(:applications_results) { ATDIS::Models::Page.read_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json") }

      it ".response" do
        application1 = double("Application")
        application2 = double("Application")
        ATDIS::Models::Response.should_receive(:interpret).with(application: {description: "application1"}).and_return(application1)
        ATDIS::Models::Response.should_receive(:interpret).with(application: {description: "application2"}).and_return(application2)

        applications_results.response.should == [application1, application2]
      end

      it ".next_page" do
        applications_results.next_page.should be_nil
      end

      it ".pagination" do
        applications_results.pagination.should be_nil
      end
      end
  end

  context "paging supported by vendor" do
    before :each do
      RestClient.should_receive(:get).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2").and_return(double(to_str: <<-EOF
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

    let(:applications_results) { ATDIS::Models::Page.read_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2") }

    it ".previous" do
      applications_results.pagination.previous.should == 1
    end

    it ".next" do
      applications_results.pagination.next.should == 3
    end

    it ".current" do
      applications_results.pagination.current.should == 2
    end

    it ".per_page" do
      applications_results.pagination.per_page.should == 2
    end

    it ".count" do
      applications_results.pagination.count.should == 50
    end

    it ".pages" do
      applications_results.pagination.pages.should == 25
    end

    it ".next_url" do
      applications_results.next_url.should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=3"
    end

    it ".next_page" do
      n = double("Page")
      applications_results
      ATDIS::Models::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=3").and_return(n)
      applications_results.next_page.should == n
    end
  end
end
