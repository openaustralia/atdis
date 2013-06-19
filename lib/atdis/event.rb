module ATDIS
  class Event < Model
    attr_accessor :id, :date, :description, :event_type, :status

    def self.interpret(data)
      # Convert values (if required)
      data[:date] = DateTime.parse(data[:date]) if data[:date]

      Event.new(data)
    end
  end
end
