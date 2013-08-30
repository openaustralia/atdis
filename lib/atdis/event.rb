module ATDIS
  class Event < Model
    define_attribute_methods ['date']

    def attribute_types
      {
        'date' => DateTime
      }
    end

    attr_accessor :id, :description, :event_type, :status
  end
end
