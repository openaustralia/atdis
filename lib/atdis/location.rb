require "rgeo/geo_json"

module ATDIS
  class Location < Model
    set_field_mappings ({
      address:        String,
      land_title_ref: LandTitleRef,
      geometry:       RGeo::GeoJSON
    })

    # Mandatory parameters
    validates :address, presence_before_type_cast: {spec_section: "4.3.3"}

    validates :geometry, geo_json: {spec_section: "4.3.3"}

    # This model is only valid if the children are valid
    validates :land_title_ref, valid: true
  end
end
