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
      values, json_left_overs = map_fields(VALID_FIELDS, data)
      values.merge(:json_left_overs => json_left_overs)
    end
  end
end
