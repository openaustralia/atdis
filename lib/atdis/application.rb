require 'multi_json'

module ATDIS
  class Application < Model
    field_mappings :application => {
      :info => {
        :dat_id => [:dat_id, String],
        :last_modified_date => [:last_modified_date, DateTime],
        :description => [:description, String],
        :authority => [:authority, String],
        :lodgement_date => [:lodgement_date, DateTime],
        :determination_date => [:determination_date, DateTime],
        :status => [:status, String],
        :notification_start_date => [:notification_start_date, DateTime],
        :notification_end_date => [:notification_end_date, DateTime],
        :officer => [:officer, String],
        :estimated_cost => [:estimated_cost, String]
      },
      :reference => {
        :more_info_url => [:more_info_url, URI],
        :comments_url => [:comments_url, URI]
      },
      :location => [:location, Location],
      :events => [:events, Event],
      :documents => [:documents, Document],
      :people => [:people, Person],
      :extended => [:extended, Object]
    }
  
    # Mandatory parameters
    validates :dat_id, :last_modified_date, :description, :authority, :lodgement_date, :determination_date, :status, 
      :more_info_url, :location, :presence_before_type_cast => true

    # Other validations
    validates :notification_start_date, :notification_end_date, :last_modified_date, :lodgement_date, :determination_date,
      :date_time => true
    validates :more_info_url, :url => true
    validates :location, :valid => true

    # TODO Validate associated like locations, events, documents, people
    # TODO Do we need to do extra checking to ensure that events, documents and people are arrays?
    # TODO Separate validation for L2 and L3 compliance?
    # TODO Validate date orders. i.e. determination_date >= lodgement_date and notification_end_date >= notification_start_date
    # TODO also last_modified_date >= lodgement_date and all the other dates. In other words we can't put a future date in. That
    # doesn't make sense in this context. Also should check dates in things like Events (to see that they're not in the future)
  end
end
