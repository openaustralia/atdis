module ATDIS
  class Application < Model
    set_field_mappings ({
      info:      [Info],
      reference: [Reference],
      location:  [Location],
      events:    [Event],
      documents: [Document],
      people:    [Person],
      extended:  [Object],
    })

    validates :info, valid: true
    validates :reference, valid: true
    validates :location, presence_before_type_cast: {spec_section: "4.3.3"}
    validates :events, presence_before_type_cast: {spec_section: "4.3.4"}
    validates :documents, presence_before_type_cast: {spec_section: "4.3.5"}

    validates :location, :events, :documents, :people, valid: true
    validates :events, :documents, array: {spec_section: "4.3.4"}
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
