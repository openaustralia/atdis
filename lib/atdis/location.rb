require "rgeo/geo_json"

module ATDIS
  class Location < Model
    field_mappings [
      [:address, [:address, String]],
      [:land_title_ref, [
        [:lot, [:lot, String]],
        [:section, [:section, String, {:none_is_nil => true}]],
        [:dpsp_id, [:dpsp_id, String]]
      ]],
      [:geometry, [:geometry, RGeo::GeoJSON]]
    ]
    # Mandatory parameters
    validates :address, :lot, :section, :dpsp_id, :presence_before_type_cast => true

    validates :geometry, :geo_json => true

    # TODO: Provide warning if dpsp_id doesn't start with "DP" or "SP"
  end
end
