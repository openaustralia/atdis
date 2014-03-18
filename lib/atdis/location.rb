require "rgeo/geo_json"

module ATDIS
  class Location < Model
    set_field_mappings [
      [:address, [:address, String]],
      [:land_title_ref, [
        [:lot, [:lot, String]],
        [:section, [:section, String, {:none_is_nil => true}]],
        [:dpsp_id, [:dpsp_id, String]]
      ]],
      [:geometry, [:geometry, RGeo::GeoJSON]]
    ]
    # Mandatory parameters
    validates :address, :lot, :section, :dpsp_id, :presence_before_type_cast => {:spec_section => "4.3.3"}

    validates :geometry, :geo_json => {:spec_section => "4.3.3"}

    # TODO: Provide warning if dpsp_id doesn't start with "DP" or "SP"
  end
end
