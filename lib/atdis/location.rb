require "rgeo/geo_json"

module ATDIS
  class Location < Model
    set_field_mappings [
      [:address, [:address, String, {:level => 1}]],
      [:land_title_ref, [
        [:lot, [:lot, String, {:level => 1}]],
        [:section, [:section, String, {:none_is_nil => true, :level => 1}]],
        [:dpsp_id, [:dpsp_id, String, {:level => 1}]]
      ]],
      [:geometry, [:geometry, RGeo::GeoJSON, {:level => 1}]]
    ]
    # Mandatory parameters
    validates :address, :lot, :section, :dpsp_id, :presence_before_type_cast => true

    validates :geometry, :geo_json => true

    # TODO: Provide warning if dpsp_id doesn't start with "DP" or "SP"
  end
end
