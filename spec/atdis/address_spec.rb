require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Address do
  context "valid address" do
    let(:a) { ATDIS::Address.new(
      street: "123 Fourfivesix Street",
      suburb: "Neutral Bay",
      postcode: "2780"
    )}

    it { a.should be_valid }

    context "postcode that is too short" do
      before(:each) { a.postcode = "278" }
      it {
        a.should_not be_valid
        a.errors.messages.should == {postcode: [ATDIS::ErrorMessage.new("is not a valid postcode", "4.3.3")]}
      }
    end
  end
end
