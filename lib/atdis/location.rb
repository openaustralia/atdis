require "rgeo/geo_json"

module ATDIS
  class Location < Model
    attr_accessor :address, :lot, :section, :dpsp_id, :geometry

    VALID_FIELDS = {
      :address => :address,
      :land_title_ref => {
        :lot => :lot,
        :section => :section,
        :dpsp_id => :dpsp_id
      },
      :geometry => :geometry
    }

    def self.convert(data)
      values, json_left_overs = map_fields(VALID_FIELDS, data)

      # Convert values
      values[:geometry] = RGeo::GeoJSON.decode(hash_symbols_to_string(values[:geometry])) if values[:geometry]

      values[:json_left_overs] = json_left_overs
      values
    end

    private

    # Converts {:foo => {:bar => "yes"}} to {"foo" => {"bar" => "yes"}}
    def self.hash_symbols_to_string(hash)
      if hash.respond_to?(:each_pair)
        result = {}
        hash.each_pair do |key, value|
          result[key.to_s] = hash_symbols_to_string(value)
        end
        result
      else
        hash
      end
    end
  end
end
