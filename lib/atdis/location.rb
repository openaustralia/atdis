module ATDIS
  class Location
    attr_accessor :address, :lot, :section, :dpsp_id

    def self.interpret(data)
      l = Location.new
      l.address = data[:address]
      if data[:land_title_ref]
        l.lot = data[:land_title_ref][:lot]
        l.section = data[:land_title_ref][:section]
        l.dpsp_id = data[:land_title_ref][:dpsp_id]
      end
      l
    end
  end
end
