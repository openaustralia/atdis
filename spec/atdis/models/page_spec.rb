# frozen_string_literal: true

require "spec_helper"

describe ATDIS::Models::Page do
  it ".attribute_names" do
    expect(ATDIS::Models::Page.attribute_names).to eq %w[response count pagination]
  end

  it "should error if response is null" do
    page = ATDIS::Models::Page.new(
      { response: nil, count: 0, pagination: { pages: 1, per_page: 20, count: 0, current: 1 } },
      "UTC"
    )
    expect(page).to_not be_valid
    expect(page.errors.messages).to eq(response: [ATDIS::ErrorMessage["can't be blank", "4.3"]])
  end

  describe "validations" do
    context "results block that is a hash" do
      before :each do
        expect(ATDIS::Models::Response).to receive(:interpret).with(
          { description: "application1" },
          "UTC"
        ).and_return(double(valid?: true))
      end
      let(:page) { ATDIS::Models::Page.new({ response: { description: "application1" } }, "UTC") }

      it do
        expect(page).to_not be_valid
        expect(page.errors.messages).to eq(
          response: [ATDIS::ErrorMessage["should be an array", "6.4"]]
        )
      end
    end

    context "two valid applications no paging" do
      before :each do
        expect(ATDIS::Models::Response).to receive(:interpret).with(
          { description: "application1" },
          "UTC"
        ).and_return(double(valid?: true))
        expect(ATDIS::Models::Response).to receive(:interpret).with(
          { description: "application2" },
          "UTC"
        ).and_return(double(valid?: true))
      end
      let(:page) do
        ATDIS::Models::Page.new(
          { response: [{ description: "application1" }, { description: "application2" }] },
          "UTC"
        )
      end

      it { expect(page).to be_valid }

      # It's not super clear in the spec whether this should be allowed but it seems sensible to
      # allow it.
      context "with a count but no pagination" do
        before :each do
          page.count = 2
        end
        it { expect(page).to be_valid }
      end

      context "with pagination" do
        before :each do
          page.count = 2
          page.pagination = ATDIS::Models::Pagination.new(
            { per_page: 25, current: 1, count: 2, pages: 1 },
            "UTC"
          )
        end
        it { expect(page).to be_valid }

        context "count is not consistent" do
          before :each do
            page.count = 1
          end
          it do
            expect(page).to_not be_valid
            expect(page.errors.messages).to eq(
              count: [
                ATDIS::ErrorMessage["is not the same as the number of applications returned", "6.4"]
              ]
            )
          end
        end

        context "count is larger than number of results per page" do
          before :each do
            page.pagination.per_page = 1
            page.pagination.count = 1
          end
          it do
            expect(page).to_not be_valid
            expect(page.errors.messages).to eq(
              count: [
                ATDIS::ErrorMessage[
                  "should not be larger than the number of results per page",
                  "6.4"
                ]
              ]
            )
          end
        end

        context "count is absent" do
          before :each do
            page.count = nil
          end

          it do
            expect(page).to_not be_valid
            expect(page.errors.messages).to eq(
              count: [ATDIS::ErrorMessage["should be present if pagination is being used", "6.4"]]
            )
          end
        end

        context "pagination not valid" do
          before :each do
            expect(page.pagination).to receive(:valid?).and_return(false)
          end

          it do
            expect(page).to_not be_valid
            expect(page.errors.messages).to eq(
              pagination: [
                ATDIS::ErrorMessage["is not valid (see further errors for details)", nil]
              ]
            )
          end
        end
      end
    end

    context "one valid application out of two no paging" do
      before :each do
        expect(ATDIS::Models::Response).to receive(:interpret).with(
          { description: "application1" },
          "UTC"
        ).and_return(double(valid?: true))
        expect(ATDIS::Models::Response).to receive(:interpret).with(
          { description: "application2" },
          "UTC"
        ).and_return(double(valid?: false))
      end
      let(:page) do
        ATDIS::Models::Page.new(
          { response: [{ description: "application1" }, { description: "application2" }] },
          "UTC"
        )
      end

      it do
        expect(page).to_not be_valid
        expect(page.errors.messages).to eq(
          response: [ATDIS::ErrorMessage["is not valid (see further errors for details)", nil]]
        )
      end
    end

    context "two invalid applications no paging" do
      let(:a1) { double(valid?: false, json_errors: [[{ dat_id: "null" }, ["can not be empty"]]]) }
      let(:a2) { double(valid?: false) }
      before :each do
        expect(ATDIS::Models::Response).to receive(:interpret).with(
          { description: "application1" },
          "UTC"
        ).and_return(a1)
        expect(ATDIS::Models::Response).to receive(:interpret).with(
          { description: "application2" },
          "UTC"
        ).and_return(a2)
      end
      let(:page) do
        ATDIS::Models::Page.new(
          { response: [{ description: "application1" }, { description: "application2" }] },
          "UTC"
        )
      end

      it do
        expect(page).to_not be_valid
        expect(page.errors.messages).to eq(
          response: [ATDIS::ErrorMessage["is not valid (see further errors for details)", nil]]
        )
      end

      it "the errors from the first errored application should be here" do
        expect(page).to_not be_valid
        expect(page.json_errors).to eq(
          [
            [
              { response: [{ description: "application1" }, { description: "application2" }] },
              [ATDIS::ErrorMessage["response is not valid (see further errors for details)"]]
            ],
            [
              { response: [{ dat_id: "null" }] },
              ["can not be empty"]
            ]
          ]
        )
      end
    end
  end

  context "paging supported by vendor" do
    context "read a from an invalid json string" do
      let(:page) do
        json = <<~JSON
          {
            "response": [
              {
                "application": {
                  "description": "application2"
                }
              }
            ],
          }
        JSON
        ATDIS::Models::Page.read_json(json, "UTC")
      end

      it do
        expect(page).to_not be_valid
        expect(page.errors.messages.key?(:json)).to be_truthy
        expect(page.errors.messages.count).to eq 1
        expect(page.errors.messages[:json].count).to eq 1
        message = page.errors.messages[:json].first
        expect(message.message).to match(/Invalid JSON: .*: unexpected token at '{/)
      end
    end

    context "read from a json string" do
      let(:page) do
        json = <<~JSON
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
        JSON
        ATDIS::Models::Page.read_json(json, "UTC")
      end
      it ".results" do
        application1 = double("Application")
        application2 = double("Application")
        expect(ATDIS::Models::Response).to receive(:interpret).with(
          { application: { description: "application1" } },
          "UTC"
        ).and_return(application1)
        expect(ATDIS::Models::Response).to receive(:interpret).with(
          { application: { description: "application2" } },
          "UTC"
        ).and_return(application2)

        expect(page.response).to eq [application1, application2]
      end

      it ".next_page" do
        expect { page.next_page }.to raise_error "Can't use next_url when loaded with read_json"
      end
    end

    context "read from a url" do
      before :each do
        # Mock network response
        json = <<-JSON
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
        JSON
        expect(ATDIS::Model).to receive(:read_url_raw).with(
          "http://www.council.nsw.gov.au/atdis/1.0/applications.json",
          false
        ).and_return(json)
      end

      let(:applications_results) do
        ATDIS::Models::Page.read_url(
          "http://www.council.nsw.gov.au/atdis/1.0/applications.json",
          "UTC"
        )
      end

      it ".response" do
        application1 = double("Application")
        application2 = double("Application")
        expect(ATDIS::Models::Response).to receive(:interpret).with(
          { application: { description: "application1" } },
          "UTC"
        ).and_return(application1)
        expect(ATDIS::Models::Response).to receive(:interpret).with(
          { application: { description: "application2" } },
          "UTC"
        ).and_return(application2)

        expect(applications_results.response).to eq [application1, application2]
      end

      it ".next_page" do
        expect(applications_results.next_page).to be_nil
      end

      it ".pagination" do
        expect(applications_results.pagination).to be_nil
      end
    end
  end

  context "paging supported by vendor" do
    before :each do
      json = <<~JSON
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
      JSON
      expect(ATDIS::Model).to receive(:read_url_raw).with(
        "http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2",
        false
      ).and_return(json)
    end

    let(:applications_results) do
      ATDIS::Models::Page.read_url(
        "http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2",
        "UTC"
      )
    end

    it ".previous" do
      expect(applications_results.pagination.previous).to eq 1
    end

    it ".next" do
      expect(applications_results.pagination.next).to eq 3
    end

    it ".current" do
      expect(applications_results.pagination.current).to eq 2
    end

    it ".per_page" do
      expect(applications_results.pagination.per_page).to eq 2
    end

    it ".count" do
      expect(applications_results.pagination.count).to eq 50
    end

    it ".pages" do
      expect(applications_results.pagination.pages).to eq 25
    end

    it ".next_url" do
      expect(applications_results.next_url).to eq "http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=3"
    end

    it ".next_page" do
      n = double("Page")
      applications_results
      expect(ATDIS::Models::Page).to receive(:read_url).with(
        "http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=3",
        "UTC"
      ).and_return(n)
      expect(applications_results.next_page).to eq n
    end
  end
end
