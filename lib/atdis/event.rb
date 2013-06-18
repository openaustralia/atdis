module ATDIS
  Event = Struct.new(:id, :date, :description, :event_type, :status) do
    def self.interpret(data)
      values = data

      # Convert values (if required)
      values[:date] = DateTime.parse(values[:date]) if values[:date]

      Event.new(*members.map{|m| values[m.to_sym]})
    end
  end
end
