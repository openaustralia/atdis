require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Feed do
  let(:feed) { ATDIS::Feed.new("http://www.council.nsw.gov.au/atdis/1.0/applications.json") }
  let(:page) { double }

  it "should return all the applications" do
    ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json").and_return(page)
    feed.applications.should == page
  end

  describe "should restrict search by postcode" do
    it "single postcode" do
      ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000").and_return(page)
      feed.applications(:postcode => 2000).should == page
    end

    it "multiple postcodes in an array" do
      ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000,2001").and_return(page)
      feed.applications(:postcode => [2000,2001]).should == page
    end

    it "multiple postcodes as a string" do
      ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?postcode=2000,2001").and_return(page)
      feed.applications(:postcode => "2000,2001").should == page
    end
  end

  describe "search by lodgement date" do
    it "just a lodgement start date as a date" do
      ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_start=2001-02-01").and_return(page)
      feed.applications(:lodgement_date_start => Date.new(2001,2,1)).should == page
    end

    it "just a lodgement start date as a string" do
      ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_start=2011-02-04").and_return(page)
      feed.applications(:lodgement_date_start => "2011-02-04").should == page
    end

    it "a lodgement start date and end date" do
      ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?lodgement_date_start=2001-02-01&lodgement_date_end=2001-03-01").and_return(page)
      feed.applications(:lodgement_date_start => Date.new(2001,2,1), :lodgement_date_end => Date.new(2001,3,1)).should == page
    end
  end

  describe "search by last modified date" do
    it "just a last modified start date" do
      ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?last_modified_date_start=2001-02-01").and_return(page)
      feed.applications(:last_modified_date_start => Date.new(2001,2,1)).should == page
    end

    it "a last modified start date and end date" do
      ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?last_modified_date_start=2001-02-01&last_modified_date_end=2001-03-01").and_return(page)
      feed.applications(:last_modified_date_start => Date.new(2001,2,1), :last_modified_date_end => Date.new(2001,3,1)).should == page
    end
  end

  it "jump straight to the second page" do
    ATDIS::Page.should_receive(:read_url).with("http://www.council.nsw.gov.au/atdis/1.0/applications.json?page=2").and_return(page)
    feed.applications(:page => 2).should == page    
  end

  it "passing an invalid option" do
    expect {feed.applications(:foo => 1)}.to raise_error "Unexpected options used: foo"
  end
end
