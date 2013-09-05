module ATDIS
  class Event < Model
    casting_attributes :date => DateTime

    attr_accessor :id, :description, :event_type, :status

    field_mappings :id => :id,
      :date => :date,
      :description => :description,
      :event_type => :event_type,
      :status => :status
  end
end
