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

    it "should gracefully handle the land_title_ref block being missing" do
      l = ATDIS::Location.interpret(:address => "123 Fourfivesix Street Neutral Bay NSW 2089")
      
      l.address.should == "123 Fourfivesix Street Neutral Bay NSW 2089"
      l.lot.should be_nil
      l.section.should be_nil
      l.dpsp_id.should be_nil
    end

    it "should pass on the responsibility for parsing the geometry section" do
      geometry = mock
      ATDIS::Geometry.should_receive(:interpret).with(:type => "Point", :coordinates => [100.0, 0.0]).and_return(geometry)
      # TODO Not 100% clear from section 4.3.3 of ATDIS-1.0.3 if this is the correct indentation
      l = ATDIS::Location.interpret(
        :geometry => {
          :type => "Point",
          :coordinates => [100.0, 0.0]
        }
      )
      l.geometry.should == geometry
    end
  end
end
