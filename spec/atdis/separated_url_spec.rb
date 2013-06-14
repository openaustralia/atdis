require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::SeparatedURL do
  let(:url) { ATDIS::SeparatedURL.parse("http://foo.com/bar?foo=twenty&bar=12") }

  describe ".url" do
    it { url.url.should == "http://foo.com/bar" }
  end

  it ".url_params" do
    url.url_params.count.should == 2
    url.url_params[:foo].should == "twenty"
    url.url_params[:bar].should == "12"
  end

  describe "#parse" do
    it { ATDIS::SeparatedURL.parse(url.full_url).should == url }
    it do
      u = ATDIS::SeparatedURL.parse("http://www.council.nsw.gov.au/atdis/1.0/applications.json")
      u.url.should == "http://www.council.nsw.gov.au/atdis/1.0/applications.json"
      u.url_params.should == {}
    end
  end

  describe ".full_url" do
    it { url.full_url.should == "http://foo.com/bar?foo=twenty&bar=12" }
  end

  describe ".merge" do
    it "should add a new parameter" do
      url.merge(:page => 2).full_url.should == "http://foo.com/bar?bar=12&foo=twenty&page=2"
    end

    it "should overwrite an existing one" do
      url.merge(:bar => 24).full_url.should == "http://foo.com/bar?bar=24&foo=twenty"
    end
  end
end
