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
      :more_info_url, :location, :events, :presence_before_type_cast => true

    # Other validations
    validates :last_modified_date, :lodgement_date, :date_time => true
    validates :determination_date, :notification_start_date, :notification_end_date, :date_time_or_none => true
    validates :more_info_url, :http_url => true
    validates :location, :valid => true
    validates :events, :array => true

    validate :notification_dates_consistent!

    def notification_dates_consistent!
      if notification_start_date_before_type_cast == "none" && notification_end_date_before_type_cast != "none"
        errors.add(:notification_start_date, "can't be none unless notification_end_date is none as well")
      end
      if notification_start_date_before_type_cast != "none" && notification_end_date_before_type_cast == "none"
        errors.add(:notification_end_date, "can't be none unless notification_start_date is none as well")
      end
      if notification_start_date_before_type_cast && notification_end_date_before_type_cast.blank?
        errors.add(:notification_end_date, "can not be blank if notification_start_date is set")
      end
      if notification_start_date_before_type_cast.blank? && notification_end_date_before_type_cast
        errors.add(:notification_start_date, "can not be blank if notification_end_date is set")
      end
      if notification_start_date && notification_end_date && notification_start_date > notification_end_date
        errors.add(:notification_end_date, "can not be earlier than notification_start_date")
      end
    end

    # TODO Validate contents of estimated_cost
    # TODO Validate associated like locations, events, documents, people
    # TODO Do we need to do extra checking to ensure that events, documents and people are arrays?
    # TODO Separate validation for L2 and L3 compliance?
    # TODO Validate date orders. i.e. determination_date >= lodgement_date and notification_end_date >= notification_start_date
    # TODO also last_modified_date >= lodgement_date and all the other dates. In other words we can't put a future date in. That
    # doesn't make sense in this context. Also should check dates in things like Events (to see that they're not in the future)
  end
end
