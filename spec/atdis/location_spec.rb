require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ATDIS::Location do
  it ".attribute_names" do
    ATDIS::Location.attribute_names.should == [
      "address",
      "land_title_ref",
      "geometry"
    ]
  end

  describe "validation" do
    context "valid location" do
      let(:l) { ATDIS::Location.new(
        address: {
          street: "123 Fourfivesix Street",
          suburb: "Neutral Bay",
          postcode: "2089"
        },
        land_title_ref: {
          torrens: {
            lot: "10",
            section: "ABC",
            dpsp_id: "DP2013-0381",            
          }
        },
        geometry: {
          type: "Point",
          coordinates: [100.0, 0.0]
        }
      )}

      it { l.should be_valid }

      it "address" do
        l.address = nil
        l.should_not be_valid
        l.errors.messages.should == {address: [ATDIS::ErrorMessage["can't be blank", "4.3.3"]]}
      end

      it "geometry" do
        l.geometry = {type: "Point"}
        l.geometry.should be_nil
        l.should_not be_valid
      end
    end
  end

  describe ".interpret" do
    it "should gracefully handle the land_title_ref block being missing" do
      l = ATDIS::Location.interpret(address: {street: "123 Fourfivesix Street", suburb: "Neutral Bay", postcode: "2089"})
      l.land_title_ref.should be_nil
    end

    it "should pass on the responsibility for parsing the geometry section" do
      # TODO Not 100% clear from section 4.3.3 of ATDIS-1.0.3 if this is the correct indentation
      l = ATDIS::Location.interpret(
        geometry: {
          type: "Point",
          coordinates: [100.0, 0.0]
        }
      )
      # TODO Check that the returned geometry is a point
      l.geometry.x.should == 100
      l.geometry.y.should == 0
    end

    it "should interpret a polygon in the geometry section" do
      # TODO Not 100% clear from section 4.3.3 of ATDIS-1.0.3 if this is the correct indentation
      l = ATDIS::Location.interpret(
        geometry: {
          type: "Polygon",
          coordinates: [
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
