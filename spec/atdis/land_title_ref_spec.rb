require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::LandTitleRef do
  let(:l) { ATDIS::LandTitleRef.new(
    lot: "10",
    section: "ABC",
    dpsp_id: "DP2013-0381"
  )}

  describe "dpsp_id" do
    it "can not be blank" do
      l.dpsp_id = ""
      l.should_not be_valid
      l.errors.messages.should == {dpsp_id: [ATDIS::ErrorMessage["can't be blank", "4.3.3"]]}
    end

    it "can be none but is not interpreted in any special way" do
      l.dpsp_id = "none"
      l.dpsp_id.should == "none"
      l.should be_valid
    end
  end

  describe "section" do
    it "can not be blank" do
      l.section = ""
      l.should_not be_valid
      l.errors.messages.should == {section: [ATDIS::ErrorMessage["can't be blank", "4.3.3"]]}
    end

    it "can be none" do
      l.section = "none"
      l.section.should be_nil
      l.should be_valid
    end
  end

  describe "lot" do
    it "can not be blank" do
      l.lot = ""
      l.should_not be_valid
      l.errors.messages.should == {lot: [ATDIS::ErrorMessage["can't be blank", "4.3.3"]]}
    end

    it "can be none but is not interpreted in any special way" do
      l.lot = "none"
      l.lot.should == "none"
      l.should be_valid
    end
  end

end
