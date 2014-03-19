require 'multi_json'

module ATDIS
  class Application < Model
    # TODO When we remove support for Ruby 1.8 we can convert field_mappings back to a hash
    # which is much more readable
    set_field_mappings [
      [:application, [
        [:info,                       [:info, Info]],
        [:reference, [
          [:more_info_url,            [:more_info_url, URI]],
          [:comments_url,             [:comments_url, URI]]
        ]],
        [:location,                   [:location, Location]],
        [:events,                     [:events, Event]],
        [:documents,                  [:documents, Document]],
        [:people,                     [:people, Person]],
        [:extended,                   [:extended, Object]]
      ]]
    ]

    validates :info, valid: true
    validates :more_info_url, presence_before_type_cast: {spec_section: "4.3.2"}
    validates :location, presence_before_type_cast: {spec_section: "4.3.3"}
    validates :events, presence_before_type_cast: {spec_section: "4.3.4"}
    validates :documents, presence_before_type_cast: {spec_section: "4.3.5"}

    validates :more_info_url, http_url: {spec_section: "4.3.2"}
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
