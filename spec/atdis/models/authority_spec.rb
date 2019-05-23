require "spec_helper"

describe ATDIS::Models::Authority do
  describe "validations" do
    context "a valid ref" do
      let(:a) { ATDIS::Models::Authority.new(ref: "http://www.council.nsw.gov.au/atdis/1.0", name: "Council")}
      it {expect(a).to be_valid}
    end

    context "a valid ref with https" do
      let(:a) { ATDIS::Models::Authority.new(ref: "https://www.council.nsw.gov.au/atdis/1.0", name: "Council")}
      it {expect(a).to be_valid}
    end

    context "an invalid ref that isn't a url" do
      let(:a) { ATDIS::Models::Authority.new(ref: "foobar", name: "Council")}
      it {
        expect(a).to_not be_valid
        expect(a.errors.messages).to eq ({ref: [
          ATDIS::ErrorMessage.new("is not a valid URL", "4.3.1"),
          ATDIS::ErrorMessage.new("is not a valid Unique Authority Identifier", "4.3.1")
        ]})
      }
    end

    context "an invalid ref because it doesn't end in atdis/1.0" do
      let(:a) { ATDIS::Models::Authority.new(ref: "http://www.council.nsw.gov.au/foobar", name: "Council")}
      it {
        expect(a).to_not be_valid
        expect(a.errors.messages).to eq ({ref: [ATDIS::ErrorMessage.new("is not a valid Unique Authority Identifier", "4.3.1")]})
      }
    end
  end
end
