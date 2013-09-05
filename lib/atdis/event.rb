module ATDIS
  class Event < Model
    casting_attributes :date => DateTime

    attr_accessor :id, :description, :event_type, :status

    VALID_FIELDS = {
      :id => :id,
      :date => :date,
      :description => :description,
      :event_type => :event_type,
      :status => :status
    }

    # TODO Do proper mapping of json parameters to our parameters
    def self.convert(data)
      map_fields2(VALID_FIELDS, data)
    end
  end
end
