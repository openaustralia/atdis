module ATDIS
  module Models
    class Event < Model
      set_field_mappings ({
        id:          String,
        timestamp:   DateTime,
        description: String,
        event_type:  String,
        status:      String
      })

      # Mandatory parameters
      validates :id, :timestamp, :description, presence_before_type_cast: {spec_section: "4.3.4"}
    end
  end
end
