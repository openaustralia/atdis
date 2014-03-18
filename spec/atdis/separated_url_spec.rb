require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::SeparatedURL do
  describe "#merge" do
    it "should add a new parameter" do
      ATDIS::SeparatedURL.merge("http://foo.com/bar?foo=twenty&bar=12", page: 2).should ==
        "http://foo.com/bar?bar=12&foo=twenty&page=2"
    end

    it "should overwrite an existing one" do
      ATDIS::SeparatedURL.merge("http://foo.com/bar?foo=twenty&bar=12", bar: 24).should ==
        "http://foo.com/bar?bar=24&foo=twenty"
    end

    it "should encode spaces for example" do
      ATDIS::SeparatedURL.merge("http://foo.com/bar?foo=twenty&bar=12", bar: "hello sir").should ==
        "http://foo.com/bar?bar=hello+sir&foo=twenty"
    end

    it "should be fine if there are no parameters" do
      ATDIS::SeparatedURL.merge("http://foo.com/bar", page: 2).should ==
        "http://foo.com/bar?page=2"
    end

    it "should be fine if there are no parameters" do
      ATDIS::SeparatedURL.merge("http://foo.com/bar", {}).should ==
        "http://foo.com/bar"
    end

    it "should be able to handle port numbers in URLS" do
      ATDIS::SeparatedURL.merge("http://foo.com:3000/bar", {}).should ==
        "http://foo.com:3000/bar"      
    end

    it "should be able to handle https" do
      ATDIS::SeparatedURL.merge("https://foo.com/bar", {}).should ==
        "https://foo.com/bar"
    end
   end
end
