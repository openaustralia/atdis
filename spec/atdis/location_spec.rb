require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Location do
  describe "validation" do
    context "valid location" do
      let(:l) { ATDIS::Location.new(
        :address => "123 Fourfivesix Street Neutral Bay NSW 2089",
        :lot => "10",
        :section => "ABC",
        :dpsp_id => "DP2013-0381",
        :geometry => {
          :type => "Point",
          :coordinates => [100.0, 0.0]
        }
      )}
      
      it { l.should be_valid }

      it "address" do
        l.address = ""
        l.should_not be_valid
        l.errors.messages.should == {:address => ["can't be blank"]}
      end

      it "geometry" do
        l.geometry = {:type => "Point"}
        l.geometry.should be_nil
        l.should_not be_valid
      end
    end
  end

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
      # TODO Not 100% clear from section 4.3.3 of ATDIS-1.0.3 if this is the correct indentation
      l = ATDIS::Location.interpret(
        :geometry => {
          :type => "Point",
          :coordinates => [100.0, 0.0]
        }
      )
      # TODO Check that the returned geometry is a point
      l.geometry.x.should == 100
      l.geometry.y.should == 0
    end

    it "should interpret a polygon in the geometry section" do
      # TODO Not 100% clear from section 4.3.3 of ATDIS-1.0.3 if this is the correct indentation
      l = ATDIS::Location.interpret(
        :geometry => {
          :type => "Polygon",
          :coordinates => [
            [ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0],
              [100.0, 1.0], [100.0, 0.0] ]
          ]
        }
      )
      # TODO Check that the returned geometry is a polygon
      l.geometry.interior_rings.should be_empty
      l.geometry.exterior_ring.points.count.should == 5
      l.geometry.exterior_ring.points[0].x.should == 100
      l.geometry.exterior_ring.points[0].y.should == 0
      l.geometry.exterior_ring.points[1].x.should == 101
      l.geometry.exterior_ring.points[1].y.should == 0
      l.geometry.exterior_ring.points[2].x.should == 101
      l.geometry.exterior_ring.points[2].y.should == 1
      l.geometry.exterior_ring.points[3].x.should == 100
      l.geometry.exterior_ring.points[3].y.should == 1
      l.geometry.exterior_ring.points[4].x.should == 100
      l.geometry.exterior_ring.points[4].y.should == 0
    end
  end
end
