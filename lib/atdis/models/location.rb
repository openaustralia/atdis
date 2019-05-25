require "atdis/models/address"
require "atdis/models/land_title_ref"
require "rgeo/geo_json"

module ATDIS
  module Models
    class Location < Model
      field_mappings(
        address:        Address,
        land_title_ref: LandTitleRef,
        geometry:       RGeo::GeoJSON
      )

      # Mandatory parameters
      validates :address, :land_title_ref, presence_before_type_cast: { spec_section: "4.3.3" }

      validates :geometry, geo_json: { spec_section: "4.3.3" }

      # This model is only valid if the children are valid
      validates :address, :land_title_ref, valid: true
    end
  end
end
