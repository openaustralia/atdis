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

      # TODO people should be an array if it's included

      # TODO Validate contents of estimated_cost
      # TODO Validate associated like locations, events, documents, people
      # TODO Do we need to do extra checking to ensure that events, documents and people are arrays?
      # TODO Separate validation for L2 and L3 compliance?
      # TODO Validate date orders. i.e. determination_date >= lodgement_date and notification_end_date >= notification_start_date
      # TODO also last_modified_date >= lodgement_date and all the other dates. In other words we can't put a future date in. That
      # doesn't make sense in this context. Also should check dates in things like Events (to see that they're not in the future)
    end
  end
end
