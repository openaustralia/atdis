module ATDIS
  class Event < Model
    set_field_mappings ({
      id:          String,
      date:        DateTime,
      description: String,
      event_type:  String,
      status:      String
    })

    # Mandatory parameters
    validates :id, :date, :description, presence_before_type_cast: {spec_section: "4.3.4"}
  end

  # TODO Check that :id is unique within an authority

end
