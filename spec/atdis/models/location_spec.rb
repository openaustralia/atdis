# frozen_string_literal: true

require "spec_helper"

describe ATDIS::Models::Location do
  it ".attribute_names" do
    expect(ATDIS::Models::Location.attribute_names).to eq %w[
      address
      land_title_ref
      geometry
    ]
  end

  describe "validation" do
    context "valid location" do
      let(:l) do
        ATDIS::Models::Location.new(
          address: {
            street: "123 Fourfivesix Street",
            suburb: "Neutral Bay",
            postcode: "2089",
            state: "NSW"
          },
          land_title_ref: {
            torrens: {
              lot: "10",
              section: "ABC",
              dpsp_id: "DP2013-0381"
            }
          },
          geometry: {
            type: "Point",
            coordinates: [100.0, 0.0]
          }
        )
      end

      it { expect(l).to be_valid }

      it "address" do
        l.address = nil
        expect(l).to_not be_valid
        expect(l.errors.messages).to eq(address: [ATDIS::ErrorMessage["can't be blank", "4.3.3"]])
      end

      it "geometry" do
        l.geometry = { type: "Point" }
        expect(l.geometry).to be_nil
        expect(l).to_not be_valid
      end
    end
  end

  describe ".interpret" do
    it "should gracefully handle the land_title_ref block being missing" do
      l = ATDIS::Models::Location.interpret(
        address: { street: "123 Fourfivesix Street", suburb: "Neutral Bay", postcode: "2089" }
      )
      expect(l.land_title_ref).to be_nil
    end

    it "should pass on the responsibility for parsing the geometry section" do
      # TODO: Not 100% clear from section 4.3.3 of ATDIS-1.0.3 if this is the correct indentation
      l = ATDIS::Models::Location.interpret(
        geometry: {
          type: "Point",
          coordinates: [100.0, 0.0]
        }
      )
      # TODO: Check that the returned geometry is a point
      expect(l.geometry.x).to eq 100
      expect(l.geometry.y).to eq 0
    end

    it "should interpret a polygon in the geometry section" do
      # TODO: Not 100% clear from section 4.3.3 of ATDIS-1.0.3 if this is the correct indentation
      l = ATDIS::Models::Location.interpret(
        geometry: {
          type: "Polygon",
          coordinates: [
            [[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0], [100.0, 0.0]]
          ]
        }
      )
      # TODO: Check that the returned geometry is a polygon
      expect(l.geometry.interior_rings).to be_empty
      expect(l.geometry.exterior_ring.points.count).to eq 5
      expect(l.geometry.exterior_ring.points[0].x).to eq 100
      expect(l.geometry.exterior_ring.points[0].y).to eq 0
      expect(l.geometry.exterior_ring.points[1].x).to eq 101
      expect(l.geometry.exterior_ring.points[1].y).to eq 0
      expect(l.geometry.exterior_ring.points[2].x).to eq 101
      expect(l.geometry.exterior_ring.points[2].y).to eq 1
      expect(l.geometry.exterior_ring.points[3].x).to eq 100
      expect(l.geometry.exterior_ring.points[3].y).to eq 1
      expect(l.geometry.exterior_ring.points[4].x).to eq 100
      expect(l.geometry.exterior_ring.points[4].y).to eq 0
    end
  end
end
