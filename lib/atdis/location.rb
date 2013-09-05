require "rgeo/geo_json"

module ATDIS
  class Location < Model
    attr_accessor :address, :lot, :section, :dpsp_id, :geometry

    field_mappings :address => :address,
      :land_title_ref => {
        :lot => :lot,
        :section => :section,
        :dpsp_id => :dpsp_id
      },
      :geometry => :geometry

    def geometry=(v)
      @geometry = Location.cast(v, RGeo::GeoJSON)
    end
  end
end
