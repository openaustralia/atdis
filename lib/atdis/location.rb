require "rgeo/geo_json"

module ATDIS
  Location = Struct.new(:address, :lot, :section, :dpsp_id, :geometry) do
    def self.interpret(data)
      values = {:address => data[:address]}
      values = values.merge(data[:land_title_ref]) if data[:land_title_ref]
      values[:geometry] = data[:geometry]

      # Convert values
      values[:geometry] = RGeo::GeoJSON.decode(hash_symbols_to_string(values[:geometry])) if values[:geometry]

      Location.new(*members.map{|m| values[m.to_sym]})
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
