require "rgeo/geo_json"

module ATDIS
  class Location < Model
    field_mappings :address => [:address, String],
      :land_title_ref => {
        :lot => [:lot, String],
        :section => [:section, String],
        :dpsp_id => [:dpsp_id, String]
      },
      :geometry => [:geometry, RGeo::GeoJSON]
  end
end
