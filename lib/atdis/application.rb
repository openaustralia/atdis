require 'multi_json'

module ATDIS
  class Application < Model
    # TODO When we remove support for Ruby 1.8 we can convert field_mappings back to a hash
    # which is much more readable
    field_mappings [
      [:application, [
        [:info, [
          [:dat_id,                   [:dat_id, String, {:level => 1}]],
          [:last_modified_date,       [:last_modified_date, DateTime, {:level => 1}]],
          [:description,              [:description, String, {:level => 1}]],
          [:authority,                [:authority, String, {:level => 1}]],
          [:lodgement_date,           [:lodgement_date, DateTime, {:level => 1}]],
          [:determination_date,       [:determination_date, DateTime, {:level => 1}]],
          [:status,                   [:status, String, {:level => 1}]],
          [:notification_start_date,  [:notification_start_date, DateTime, {:level => 1}]],
          [:notification_end_date,    [:notification_end_date, DateTime, {:level => 1}]],
          [:officer,                  [:officer, String, {:level => 1}]],
          [:estimated_cost,           [:estimated_cost, String, {:level => 1}]]
        ]],
        [:reference, [
          [:more_info_url,            [:more_info_url, URI, {:level => 1}]],
          [:comments_url,             [:comments_url, URI, {:level => 1}]]
        ]],
        [:location,                   [:location, Location, {:level => 1}]],
        [:events,                     [:events, Event, {:level => 1}]],
        [:documents,                  [:documents, Document, {:level => 1}]],
        [:people,                     [:people, Person, {:level => 2}]],
        [:extended,                   [:extended, Object, {:level => 3}]]
      ]]
    ]

    # Mandatory parameters
    validates :dat_id, :last_modified_date, :description, :authority, :lodgement_date, :determination_date, :status, 
      :more_info_url, :location, :events, :documents, :presence_before_type_cast => true

    # Other validations
    validates :last_modified_date, :lodgement_date, :date_time => true
    validates :determination_date, :notification_start_date, :notification_end_date, :date_time_or_none => true
    validates :more_info_url, :http_url => true
    validates :location, :valid => true
    validates :events, :documents, :array => true
    # TODO people should be an array if it's included

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
