require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Feed do
  let(:feed) { ATDIS::Feed.new("http://www.council.nsw.gov.au/atdis/1.0") }
  let(:page) { double }

  it "should return all the applications" do
  expect(ATDIS::Models::Page).to receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json").and_return(page)
    feed.applications.should == page
  end

  it "should return all the applications" do
    feed.applications_url.should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json"
  end

  describe "should restrict search by postcode" do
    it "single postcode" do
      feed.applications_url(postcode: 2000).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000"
    end

    it "multiple postcodes in an array" do
      feed.applications_url(postcode: [2000,2001]).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000,2001"
    end

    it "multiple postcodes as a string" do
      feed.applications_url(postcode: "2000,2001").should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000,2001"
    end
  end

  describe "search by lodgement date" do
    it "just a lodgement start date as a date" do
      feed.applications_url(lodgement_date_start: Date.new(2001,2,1)).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_start=2001-02-01"
    end

    it "just a lodgement start date as a string" do
      feed.applications_url(lodgement_date_start: "2011-02-04").should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_start=2011-02-04"
    end

    it "a lodgement start date and end date" do
      feed.applications_url(lodgement_date_start: Date.new(2001,2,1), lodgement_date_end: Date.new(2001,3,1)).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_end=2001-03-01&lodgement_date_start=2001-02-01"
    end
  end

  describe "search by last modified date" do
    it "just a last modified start date" do
      feed.applications_url(last_modified_date_start: Date.new(2001,2,1)).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?last_modified_date_start=2001-02-01"
    end

    it "a last modified start date and end date" do
      feed.applications_url(last_modified_date_start: Date.new(2001,2,1), last_modified_date_end: Date.new(2001,3,1)).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?last_modified_date_end=2001-03-01&last_modified_date_start=2001-02-01"
    end
  end

  describe "search by suburb" do
    it do
      feed.applications_url(suburb: ["willow tree", "foo", "bar"]).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?suburb=willow+tree,foo,bar"
    end
  end

  it "jump straight to the second page" do
    feed.applications_url(page: 2).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2"
  end

  it "passing an invalid option" do
    expect {feed.applications_url(foo: 1)}.to raise_error "Unexpected options used: foo"
  end

  describe ".base_url_from_url" do
    it { ATDIS::Feed.base_url_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000").should == "http://www.council.nsw.gov.au/atdis/1.0" }
    it { ATDIS::Feed.base_url_from_url("http://www.foo.nsw.gov.au/prefix/atdis/1.0/applications.json?postcode=2000#bar").should == "http://www.foo.nsw.gov.au/prefix/atdis/1.0" }
    it "should assume that any query parameters that are not recognised are part of the base_url" do
      ATDIS::Feed.base_url_from_url("http://www.foo.nsw.gov.au/prefix/atdis/1.0/applications.json?postcode=2000&foo=bar").should == "http://www.foo.nsw.gov.au/prefix/atdis/1.0?foo=bar"
    end
  end

  describe ".options_from_url" do
    it { ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json").should == {} }
    it { ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2").should == {page: 2} }
    it { ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000,2001").should == {postcode: "2000,2001"} }
    it { ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_end=2001-03-01&lodgement_date_start=2001-02-01").should ==
      {lodgement_date_start: Date.new(2001,2,1), lodgement_date_end: Date.new(2001,3,1)} }
    it { ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?last_modified_date_end=2001-03-01&last_modified_date_start=2001-02-01").should ==
      {last_modified_date_start: Date.new(2001,2,1), last_modified_date_end: Date.new(2001,3,1)} }
    it "should assume that any query parameters that are not recognised are part of the base_url" do
      ATDIS::Feed.options_from_url("http://www.foo.nsw.gov.au/prefix/atdis/1.0/applications.json?postcode=2000&foo=bar").should == {postcode: "2000"}
    end

    it do
        ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?suburb=willow+tree,foo,bar").should == {suburb: "willow tree,foo,bar"}
    end

    it do
      ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?suburb=&postcode=2000").should == {postcode: "2000", suburb: nil}
    end
  end

  describe "#application_url" do
    it { feed.application_url("27B6").should == "http://www.council.nsw.gov.au/atdis/1.0/27B6.json" }
    it { feed.application_url("27B stroke 6").should == "http://www.council.nsw.gov.au/atdis/1.0/27B+stroke+6.json" }
    it { feed.application_url("27B/6").should == "http://www.council.nsw.gov.au/atdis/1.0/27B%2F6.json" }
  end

  describe "#application" do
    it {
      application = double
      expect(ATDIS::Models::Application).to receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/27B%2F6.json").and_return(application)
      feed.application("27B/6").should == application
    }
  end
end
