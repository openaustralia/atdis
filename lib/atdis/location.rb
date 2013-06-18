module ATDIS
  Location = Struct.new(:address, :lot, :section, :dpsp_id, :geometry) do
    def self.interpret(data)
      values = {:address => data[:address]}
      values = values.merge(data[:land_title_ref]) if data[:land_title_ref]
      values[:geometry] = data[:geometry]

      # Convert values
      values[:geometry] = Geometry.interpret(values[:geometry]) if values[:geometry]

      Location.new(*members.map{|m| values[m.to_sym]})
    end
  end
end
