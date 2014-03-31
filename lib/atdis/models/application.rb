require "atdis/models/info"
require "atdis/models/reference"
require "atdis/models/location"
require "atdis/models/event"
require "atdis/models/document"
require "atdis/models/person"

module ATDIS
  module Models
    class Application < Model
      set_field_mappings ({
        info:      Info,
        reference: Reference,
        locations: Location,
        events:    Event,
        documents: Document,
        people:    Person,
        extended:  Object,
      })

      # Mandatory attributes
      validates :info, :reference, :locations, :events, :documents, presence_before_type_cast: {spec_section: "4.3"}

      validates :people, array: {spec_section: "4.3"}
      validates :locations, :events, :documents, filled_array: {spec_section: "4.3"}

      # This model is only valid if the children are valid
      validates :info, :reference, :locations, :events, :documents, :people, valid: true
    end
  end
end
