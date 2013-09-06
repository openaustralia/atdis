module ATDIS
  class Event < Model
    field_mappings2 :id => [:id, String],
      :date => [:date, DateTime],
      :description => [:description, String],
      :event_type => [:event_type, String],
      :status => [:status, String]
  end
end
