module ATDIS
  Location = Struct.new(:address, :lot, :section, :dpsp_id) do
    def self.interpret(data)
      values = {:address => data[:address]}
      values = values.merge(data[:land_title_ref]) if data[:land_title_ref]

      Location.new(*members.map{|m| values[m.to_sym]})
    end
  end
end
