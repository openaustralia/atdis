require "spec_helper"

describe ATDIS::Models::Reference do
  let(:a) { ATDIS::Models::Reference.new(
    more_info_url: URI.parse("http://foo.com/bar"),
  )}

  describe ".more_info_url" do
    it do
      a.more_info_url = nil
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq ({more_info_url: [ATDIS::ErrorMessage["can't be blank", "4.3.2"]]})
    end
    it do
      a.more_info_url = "This is not a valid url"
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq ({more_info_url: [ATDIS::ErrorMessage["is not a valid URL", "4.3.2"]]})
    end
    it do
      a.more_info_url = "foo.com"
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq ({more_info_url: [ATDIS::ErrorMessage["is not a valid URL", "4.3.2"]]})
    end
    it do
      a.more_info_url = "httpss://foo.com"
      expect(a).to_not be_valid
      expect(a.errors.messages).to eq ({more_info_url: [ATDIS::ErrorMessage["is not a valid URL", "4.3.2"]]})
    end
  end

  describe "#more_info_url=" do
    let(:a) { ATDIS::Models::Reference.new }
    it "should do no type casting when it's already a URI" do
      a.more_info_url = URI.parse("http://foo.com/bar")
      expect(a.more_info_url).to eq URI.parse("http://foo.com/bar")
    end

    it "should cast a string to a URI when it's a valid url" do
      a.more_info_url = "http://foo.com/bar"
      expect(a.more_info_url).to eq URI.parse("http://foo.com/bar")
    end

    context "not a valid url" do
      before :each do
        a.more_info_url = "This is not a url"
      end
      it "should be nil" do
        expect(a.more_info_url).to be_nil
      end
      it "should keep the original string" do
        expect(a.more_info_url_before_type_cast).to eq "This is not a url"
      end
    end
  end
end
