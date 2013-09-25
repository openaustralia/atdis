require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Feed do
  let(:feed) { ATDIS::Feed.new("http://www.council.nsw.gov.au/atdis/1.0/applications.json") }
  let(:page) { double }

  it "should return all the applications" do
    ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json").and_return(page)
    feed.applications.should == page
  end

  it "should return all the applications" do
    feed.url.should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json"
  end

  describe "should restrict search by postcode" do
    it "single postcode" do
      feed.url(:postcode => 2000).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000"
    end

    it "multiple postcodes in an array" do
      feed.url(:postcode => [2000,2001]).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000,2001"
    end

    it "multiple postcodes as a string" do
      feed.url(:postcode => "2000,2001").should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000,2001"
    end
  end

  describe "search by lodgement date" do
    it "just a lodgement start date as a date" do
      feed.url(:lodgement_date_start => Date.new(2001,2,1)).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_start=2001-02-01"
    end

    it "just a lodgement start date as a string" do
      feed.url(:lodgement_date_start => "2011-02-04").should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_start=2011-02-04"
    end

    it "a lodgement start date and end date" do
      feed.url(:lodgement_date_start => Date.new(2001,2,1), :lodgement_date_end => Date.new(2001,3,1)).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_end=2001-03-01&lodgement_date_start=2001-02-01"
    end
  end

  describe "search by last modified date" do
    it "just a last modified start date" do
      feed.url(:last_modified_date_start => Date.new(2001,2,1)).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?last_modified_date_start=2001-02-01"
    end

    it "a last modified start date and end date" do
      feed.url(:last_modified_date_start => Date.new(2001,2,1), :last_modified_date_end => Date.new(2001,3,1)).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?last_modified_date_end=2001-03-01&last_modified_date_start=2001-02-01"
    end
  end

  it "jump straight to the second page" do
    feed.url(:page => 2).should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2"    
  end

  it "passing an invalid option" do
    expect {feed.url(:foo => 1)}.to raise_error "Unexpected options used: foo"
  end

  describe ".base_url_from_url" do
    it { ATDIS::Feed.base_url_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000").should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json" }
    it { ATDIS::Feed.base_url_from_url("http://www.foo.nsw.gov.au/prefix/atdis/1.0/applications.json?postcode=2000#bar").should == "http://www.foo.nsw.gov.au/prefix/atdis/1.0/applications.json" }
  end

  describe ".options_from_url" do
    it { ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json").should == {} }
    it { ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2").should == {:page => 2} }
    it { ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000,2001").should == {:postcode => "2000,2001"} }
    it { ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_end=2001-03-01&lodgement_date_start=2001-02-01").should ==
      {:lodgement_date_start => Date.new(2001,2,1), :lodgement_date_end => Date.new(2001,3,1)} }
    it { ATDIS::Feed.options_from_url("http://www.council.nsw.gov.au/atdis/1.0/applications.json?last_modified_date_end=2001-03-01&last_modified_date_start=2001-02-01").should ==
      {:last_modified_date_start => Date.new(2001,2,1), :last_modified_date_end => Date.new(2001,3,1)} }
  end
end
