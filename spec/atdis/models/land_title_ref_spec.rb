require "spec_helper"

describe ATDIS::Models::LandTitleRef do
  context "torrens" do
    before(:each) {
      m = double
      ATDIS::Models::TorrensTitle.should_receive(:interpret).with({lot: "10"}).and_return(m)
      m.should_receive(:valid?).and_return(true)
    }
    let(:l) { ATDIS::Models::LandTitleRef.new(torrens: {lot: "10"}) }
    it { l.should be_valid }
  end

  context "other" do
    let(:l) { ATDIS::Models::LandTitleRef.new(other: {some: "foo", random: "stuff"})}
    it { l.should be_valid }
  end

  context "no torrens or other" do
    let(:l) { ATDIS::Models::LandTitleRef.new }
    it {
      l.should_not be_valid
      l.errors.messages.should == {torrens: [ATDIS::ErrorMessage.new("or other needs be present", "4.3.3")]}
    }
  end

  context "both torrens and other" do
    before(:each) {
      m = double
      ATDIS::Models::TorrensTitle.should_receive(:interpret).with({lot: "10"}).and_return(m)
      m.should_receive(:valid?).and_return(true)
    }
    let(:l) { ATDIS::Models::LandTitleRef.new(torrens: {lot: "10"}, other: {some: "foo", random: "stuff"})}
    it {
      l.should_not be_valid
      l.errors.messages.should == {torrens: [ATDIS::ErrorMessage.new("and other can't both be present", "4.3.3")]}
    }
  end
end
