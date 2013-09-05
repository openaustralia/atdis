require "rgeo/geo_json"

module ATDIS
  class Location < Model
    field_mappings :address => :address,
      :land_title_ref => {
        :lot => :lot,
        :section => :section,
        :dpsp_id => :dpsp_id
      },
      :geometry => :geometry

    casting_attributes :address => String,
      :lot => String,
      :section => String,
      :dpsp_id => String,
      :geometry => RGeo::GeoJSON
  end
end
