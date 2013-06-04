require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Location do
  describe ".interpret" do
    it "should interpret a parsed json block of location data" do
      l = ATDIS::Location.interpret(
        :address => "123 Fourfivesix Street Neutral Bay NSW 2089",
        :land_title_ref => {
          :lot => "10",
          :section => "ABC",
          :dpsp_id => "DP2013-0381"
        })
      
      l.address.should == "123 Fourfivesix Street Neutral Bay NSW 2089"
      l.lot.should == "10"
      l.section.should == "ABC"
      l.dpsp_id.should == "DP2013-0381"
    end
  end
end
