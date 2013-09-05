module ATDIS
  class Event < Model
    casting_attributes :date => DateTime

    attr_accessor :id, :description, :event_type, :status

    # TODO Do proper mapping of json parameters to our parameters
    def self.convert(data)
      data.merge(:json_left_overs => {})
    end
  end
end
