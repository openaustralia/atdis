require 'atdis/address'
require "atdis/land_title_ref"
require "rgeo/geo_json"

module ATDIS
  class Location < Model
    set_field_mappings ({
      address:        Address,
      land_title_ref: LandTitleRef,
      geometry:       RGeo::GeoJSON
    })

    # Mandatory parameters
    validates :address, :land_title_ref, presence_before_type_cast: {spec_section: "4.3.3"}

    validates :geometry, geo_json: {spec_section: "4.3.3"}

    # This model is only valid if the children are valid
    validates :address, :land_title_ref, valid: true
  end
end
