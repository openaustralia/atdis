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

    # Mandatory parameters
    validates :address, :lot, :section, :dpsp_id, :presence_before_type_cast => true

    validates :geometry, :geo_json => true

    # TODO Would be nice to handle these specialised casting behaviour
    # by adding options to the defined casting above. Perhaps something like:
    # :lot => [:lot, String, :none_is_nil => true]
    def lot=(l)
      # Special handling for "none" value
      if l == "none"
        @attributes_before_type_cast["lot"] = l
        @attributes["lot"] = nil
      else
        super
      end
    end

    def section=(l)
      # Special handling for "none" value
      if l == "none"
        @attributes_before_type_cast["section"] = l
        @attributes["section"] = nil
      else
        super
      end
    end

    def dpsp_id=(l)
      # Special handling for "none" value
      if l == "none"
        @attributes_before_type_cast["dpsp_id"] = l
        @attributes["dpsp_id"] = nil
      else
        super
      end
    end
  end
end
