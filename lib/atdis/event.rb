module ATDIS
  class Event < Model
    casting_attributes :id => String,
      :date => DateTime,
      :description => String,
      :event_type => String,
      :status => String

    field_mappings :id => :id,
      :date => :date,
      :description => :description,
      :event_type => :event_type,
      :status => :status
  end
end
