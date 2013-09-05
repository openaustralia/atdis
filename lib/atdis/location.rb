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
      @geometry = RGeo::GeoJSON.decode(Location.hash_symbols_to_string(v)) if v
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
