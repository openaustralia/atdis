# frozen_string_literal: true

require "spec_helper"

describe ATDIS::Models::Info do
  let(:a) do
    ATDIS::Models::Info.new(
      {
        dat_id: "DA2013-0381",
        development_type: "residential",
        application_type: "DA",
        last_modified_date: DateTime.new(2013, 4, 20, 2, 1, 7),
        description: "New pool plus deck",
        authority: {
          ref: "http://www.council.nsw.gov.au/atdis/1.0",
          name: "Example Council Shire Council"
        },
        lodgement_date: DateTime.new(2013, 4, 20, 2, 1, 7),
        determination_date: DateTime.new(2013, 6, 20),
        determination_type: "Pending",
        status: "OPEN"
      },
      "UTC"
    )
  end

  describe "determination_type" do
    context "is missing" do
      before(:each) { a.determination_type = nil }
      it {
        expect(a).to_not be_valid
        expect(a.errors.messages).to eq(
          determination_type: [
            ATDIS::ErrorMessage.new("does not have one of the allowed types", "4.3.1")
          ]
        )
      }
    end

    context "is valid and Pending" do
      before(:each) { a.determination_type = "Pending" }
      it { expect(a).to be_valid }
    end

    context "is not valid because it's not one of the set of allowed ones" do
      before(:each) { a.determination_type = "Something random" }
      it {
        expect(a).to_not be_valid
        expect(a.errors.messages).to eq(
          determination_type: [
            ATDIS::ErrorMessage.new("does not have one of the allowed types", "4.3.1")
          ]
        )
      }
    end
  end

  describe "notification_date" do
    it "both valid start and end dates" do
      a.notification_start_date = DateTime.new(2013, 4, 20, 2, 1, 7)
      a.notification_end_date = DateTime.new(2013, 5, 20, 0, 0, 0)
      expect(a).to be_valid
    end

    it "invalid start date" do
      a.notification_start_date = "18 January 2013"
      a.notification_end_date = DateTime.new(2013, 2, 1, 0, 0, 0)
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        notification_start_date: [
          ATDIS::ErrorMessage["is not a valid date", "4.3.1"]
        ]
      )
    end

    it "invalid end date" do
      a.notification_start_date = DateTime.new(2013, 1, 10, 0, 0, 0)
      a.notification_end_date = "18 January 2013"
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        notification_end_date: [
          ATDIS::ErrorMessage["is not a valid date", "4.3.1"]
        ]
      )
    end

    it "only start date set" do
      a.notification_start_date = DateTime.new(2013, 4, 20, 2, 1, 7)
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        notification_end_date: [
          ATDIS::ErrorMessage["can not be blank if notification_start_date is set", "4.3.1"]
        ]
      )
    end

    it "only end date set" do
      a.notification_end_date = DateTime.new(2013, 4, 20, 2, 1, 7)
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        notification_start_date: [
          ATDIS::ErrorMessage["can not be blank if notification_end_date is set", "4.3.1"]
        ]
      )
    end

    it "end date is before start date" do
      a.notification_start_date = DateTime.new(2013, 5, 20, 0, 0, 0)
      a.notification_end_date = DateTime.new(2013, 4, 20, 2, 1, 7)
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        notification_end_date: [
          ATDIS::ErrorMessage["can not be earlier than notification_start_date", "4.3.1"]
        ]
      )
    end

    it "both dates set to null" do
      a.notification_start_date = nil
      a.notification_end_date = nil
      expect(a.notification_start_date).to be_nil
      expect(a.notification_end_date).to be_nil
      expect(a).to be_valid
    end

    it "only start date set to null" do
      a.notification_start_date = nil
      a.notification_end_date = DateTime.new(2013, 2, 1, 0, 0, 0)
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        notification_start_date: [
          ATDIS::ErrorMessage["can not be blank if notification_end_date is set", "4.3.1"]
        ]
      )
    end

    it "only end date set to null" do
      a.notification_start_date = DateTime.new(2013, 2, 1, 0, 0, 0)
      a.notification_end_date = nil
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        notification_end_date: [
          ATDIS::ErrorMessage["can not be blank if notification_start_date is set", "4.3.1"]
        ]
      )
    end
  end

  describe ".status" do
    it do
      a.status = nil
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(status: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]])
    end
  end

  describe ".determination_date" do
    it do
      a.determination_date = nil
      expect(a).to be_valid
    end
    it do
      a.determination_date = "2013-01-18"
      expect(a).to be_valid
    end
    it do
      a.determination_date = "2013-18-01"
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        determination_date: [ATDIS::ErrorMessage["is not a valid date", "4.3.1"]]
      )
    end
    it do
      a.determination_date = "18 January 2013"
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        determination_date: [ATDIS::ErrorMessage["is not a valid date", "4.3.1"]]
      )
    end
    it "nil should be allowed if the application is not yet determined" do
      a.determination_date = nil
      expect(a.determination_date).to be_nil
      expect(a).to be_valid
    end
  end

  describe ".lodgement_date" do
    it do
      a.lodgement_date = nil
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        lodgement_date: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]]
      )
    end
    it do
      a.lodgement_date = "18 January 2013"
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        lodgement_date: [ATDIS::ErrorMessage["is not a valid date", "4.3.1"]]
      )
    end
  end

  describe ".authority" do
    it do
      a.authority = nil
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(authority: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]])
    end
  end

  describe ".description" do
    it do
      a.description = ""
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(description: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]])
    end
  end

  describe ".last_modified_date" do
    it do
      a.last_modified_date = nil
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        last_modified_date: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]]
      )
    end
    it do
      a.last_modified_date = "18 January 2013"
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        last_modified_date: [ATDIS::ErrorMessage["is not a valid date", "4.3.1"]]
      )
    end
  end

  describe ".dat_id" do
    it ".dat_id" do
      a.dat_id = nil
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        dat_id: [ATDIS::ErrorMessage["can't be blank", "4.3.1"]]
      )
    end

    it "should be url encoded" do
      a.dat_id = "foo bar"
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq(
        dat_id: [ATDIS::ErrorMessage["should be url encoded", "4.3.1"]]
      )
    end

    it "should be valid if url encoded" do
      a.dat_id = "010%2F2014%2F00000031%2F001"
      expect(a).to be_valid
    end
  end

  describe "#description=" do
    let(:a) { ATDIS::Models::Info.new({}, "UTC") }
    it "should do not type casting when it's already a String" do
      a.description = "foo"
      expect(a.description).to eq "foo"
    end
    context "not a string" do
      before :each do
        a.description = 123
      end
      it "should cast to a string when it's not a string" do
        expect(a.description).to eq "123"
      end
      it "should keep the original value" do
        expect(a.description_before_type_cast).to eq 123
      end
    end
  end

  describe "#lodgement_date=" do
    let(:a) { ATDIS::Models::Info.new({}, "UTC") }
    it "should do no type casting when it's already a date" do
      a.lodgement_date = DateTime.new(2013, 1, 1)
      expect(a.lodgement_date).to eq DateTime.new(2013, 1, 1)
    end

    it "should cast a string to a date when it's a valid date" do
      a.lodgement_date = "2013-01-01"
      expect(a.lodgement_date).to eq DateTime.new(2013, 1, 1)
    end

    context "not a valid date" do
      before :each do
        a.lodgement_date = "2013/01/01"
      end
      it "should be nil" do
        expect(a.lodgement_date).to be_nil
      end
      it "should keep the original string" do
        expect(a.lodgement_date_before_type_cast).to eq "2013/01/01"
      end
    end
  end

  describe "#last_modified_date=" do
    let(:a) { ATDIS::Models::Info.new({}, "UTC") }
    it "should do no type casting when it's already a date" do
      a.last_modified_date = DateTime.new(2013, 1, 1)
      expect(a.last_modified_date).to eq DateTime.new(2013, 1, 1)
    end

    it "should cast a string to a date when it's a valid date" do
      a.last_modified_date = "2013-01-01"
      expect(a.last_modified_date).to eq DateTime.new(2013, 1, 1)
    end

    context "not a valid date" do
      before :each do
        a.last_modified_date = "2013/01/01"
      end
      it "should be nil" do
        expect(a.last_modified_date).to be_nil
      end
      it "should keep the original string" do
        expect(a.last_modified_date_before_type_cast).to eq "2013/01/01"
      end
    end
  end

  describe "related_apps" do
    context "is missing" do
      before(:each) { a.related_apps = nil }
      it { expect(a).to be_valid }
    end

    context "is not an array" do
      before(:each) do
        a.related_apps = "http://www.council.nsw.gov.au/atdis/1.0/2014_20-022DA.json"
      end
      it {
        expect(a).to_not be_valid
        expect(a.errors.messages).to eq(
          related_apps: [ATDIS::ErrorMessage.new("should be an array", "4.3.1")]
        )
      }
    end

    context "are all valid URLs that uniquely identifies a DA" do
      before(:each) do
        a.related_apps = [
          "http://www.council.nsw.gov.au/atdis/1.0/2014_20-022DA.json",
          "http://www.council.nsw.gov.au/foo/bar/atdis/1.0/sdjfsd.json"
        ]
      end
      it { expect(a).to be_valid }
    end

    context "are all valid URLs but one does not end in json" do
      before(:each) do
        a.related_apps = [
          "http://www.council.nsw.gov.au/atdis/1.0/2014_20-022DA.json",
          "http://www.council.nsw.gov.au/foo/bar/atdis/1.0/sdjfsd"
        ]
      end
      it {
        expect(a).to_not be_valid
        expect(a.errors.messages).to eq(
          related_apps: [
            ATDIS::ErrorMessage.new("contains url(s) not in the expected format", "4.3.1")
          ]
        )
      }
    end

    context "contains an invalid URL" do
      before(:each) do
        a.related_apps = [
          "http://www.council.nsw.gov.au/atdis/1.0/2014_20-022DA.json",
          "foobar"
        ]
      end
      it {
        expect(a).to_not be_valid
        expect(a.errors.messages).to eq(
          related_apps: [
            ATDIS::ErrorMessage.new("contains an invalid URL", "4.3.1"),
            ATDIS::ErrorMessage.new("contains url(s) not in the expected format", "4.3.1")
          ]
        )
      }
    end
  end
end
