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
      :people => [:people, Person]
    }
  
    validates :dat_id, :description, :authority, :status, :presence => true
    validates :last_modified_date, :lodgement_date, :determination_date, :presence_before_type_cast => true, :date_time => true
    validates :more_info_url, :presence_before_type_cast => true, :url => true
    # Optional
    validates :notification_start_date, :notification_end_date, :date_time => true

    # TODO Validate associated like locations, events, documents, people
    # TODO Add support for "extended" json parameters
    # TODO Do we need to do extra checking to ensure that events, documents and people are arrays?
  end
end
