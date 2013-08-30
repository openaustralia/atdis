module ATDIS
  class Event < Model
    attr_accessor :id, :date, :description, :event_type, :status

    def self.convert(data)
      # Convert values (if required)
      data[:date] = cast_datetime(data[:date]) if data[:date]
      data
    end
  end
end
