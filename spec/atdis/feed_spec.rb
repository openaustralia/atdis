# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe ATDIS::Feed do
  let(:feed) { ATDIS::Feed.new("http://www.council.nsw.gov.au/atdis/1.0") }
  let(:page) { double }

  it "should return all the applications" do
    expect(ATDIS::Models::Page).to receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json").and_return(page)
    expect(feed.applications).to eq page
  end

  it "should return all the applications" do
    expect(feed.applications_url).to eq "http://www.council.nsw.gov.au/atdis/1.0/applications.json"
  end

  describe "should restrict search by postcode" do
    it "single postcode" do
      expect(feed.applications_url(postcode: 2000)).to eq "http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000"
    end

    it "multiple postcodes in an array" do
      expect(feed.applications_url(postcode: [2000, 2001])).to eq "http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000,2001"
    end

    it "multiple postcodes as a string" do
      expect(feed.applications_url(postcode: "2000,2001")).to eq "http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000,2001"
    end
  end

  describe "search by lodgement date" do
    it "just a lodgement start date as a date" do
      expect(feed.applications_url(lodgement_date_start: Date.new(2001, 2, 1))).to eq "http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_start=2001-02-01"
    end

    it "just a lodgement start date as a string" do
      expect(feed.applications_url(lodgement_date_start: "2011-02-04")).to eq "http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_start=2011-02-04"
    end

    it "a lodgement start date and end date" do
      expect(feed.applications_url(lodgement_date_start: Date.new(2001, 2, 1), lodgement_date_end: Date.new(2001, 3, 1))).to eq "http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_end=2001-03-01&lodgement_date_start=2001-02-01"
    end
  end

  describe "search by last modified date" do
    it "just a last modified start date" do
      expect(feed.applications_url(last_modified_date_start: Date.new(2001, 2, 1))).to eq "http://www.council.nsw.gov.au/atdis/1.0/applications.json?last_modified_date_start=2001-02-01"
    end

    it "a last modified start date and end date" do
      expect(feed.applications_url(last_modified_date_start: Date.new(2001, 2, 1), last_modified_date_end: Date.new(2001, 3, 1))).to eq "http://www.council.nsw.gov.au/atdis/1.0/applications.json?last_modified_date_end=2001-03-01&last_modified_date_start=2001-02-01"
    end
  end

  describe "search by suburb" do
    it do
      expect(feed.applications_url(suburb: ["willow tree", "foo", "bar"])).to eq "http://www.council.nsw.gov.au/atdis/1.0/applications.json?suburb=willow+tree,foo,bar"
    end
  end

  it "jump straight to the second page" do
    expect(feed.applications_url(page: 2)).to eq "http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2"
  end

  it "passing an invalid option" do
    expect { feed.applications_url(foo: 1) }.to raise_error "Unexpected options used: foo"
  end

  describe ".base_url_from_url" do
    it { expect(ATDIS::Feed.base_url_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000")).to eq "http://www.council.nsw.gov.au/atdis/1.0" }
    it { expect(ATDIS::Feed.base_url_from_url("http://www.foo.nsw.gov.au/prefix/atdis/1.0/applications.json?postcode=2000#bar")).to eq "http://www.foo.nsw.gov.au/prefix/atdis/1.0" }
    it "should assume that any query parameters that are not recognised are part of the base_url" do
      expect(ATDIS::Feed.base_url_from_url("http://www.foo.nsw.gov.au/prefix/atdis/1.0/applications.json?postcode=2000&foo=bar")).to eq "http://www.foo.nsw.gov.au/prefix/atdis/1.0?foo=bar"
    end
  end

  describe ".options_from_url" do
    it { expect(ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json")).to eq({}) }
    it { expect(ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2")).to eq(page: 2) }
    it { expect(ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000,2001")).to eq(postcode: "2000,2001") }
    it do
      expect(ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_end=2001-03-01&lodgement_date_start=2001-02-01")).to eq(
        lodgement_date_start: Date.new(2001, 2, 1), lodgement_date_end: Date.new(2001, 3, 1)
      )
    end
    it do
      expect(ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?last_modified_date_end=2001-03-01&last_modified_date_start=2001-02-01")).to eq(
        last_modified_date_start: Date.new(2001, 2, 1), last_modified_date_end: Date.new(2001, 3, 1)
      )
    end
    it "should assume that any query parameters that are not recognised are part of the base_url" do
      expect(ATDIS::Feed.options_from_url("http://www.foo.nsw.gov.au/prefix/atdis/1.0/applications.json?postcode=2000&foo=bar")).to eq(postcode: "2000")
    end

    it do
      expect(ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?suburb=willow+tree,foo,bar")).to eq(suburb: "willow tree,foo,bar")
    end

    it do
      expect(ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?suburb=&postcode=2000")).to eq(postcode: "2000", suburb: nil)
    end
  end

  describe "#application_url" do
    it { expect(feed.application_url("27B6")).to eq "http://www.council.nsw.gov.au/atdis/1.0/27B6.json" }
    it { expect(feed.application_url("27B stroke 6")).to eq "http://www.council.nsw.gov.au/atdis/1.0/27B+stroke+6.json" }
    it { expect(feed.application_url("27B/6")).to eq "http://www.council.nsw.gov.au/atdis/1.0/27B%2F6.json" }
  end

  describe "#application" do
    it {
      application = double
      expect(ATDIS::Models::Application).to receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/27B%2F6.json").and_return(application)
      expect(feed.application("27B/6")).to eq application
    }
  end
end
