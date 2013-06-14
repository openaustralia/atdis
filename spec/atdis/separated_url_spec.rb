require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::SeparatedURL do
  let(:url) { ATDIS::SeparatedURL.new("http://foo.com/bar?foo=twenty&bar=12") }

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
