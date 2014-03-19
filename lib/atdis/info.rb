module ATDIS
  class Info < Model
    set_field_mappings [
      [:dat_id,                   [:dat_id, String]],
      [:development_type,         [:development_type, String]],
      [:last_modified_date,       [:last_modified_date, DateTime]],
      [:description,              [:description, String]],
      [:authority,                [:authority, String]],
      [:lodgement_date,           [:lodgement_date, DateTime]],
      [:determination_date,       [:determination_date, DateTime]],
      [:status,                   [:status, String]],
      [:notification_start_date,  [:notification_start_date, DateTime]],
      [:notification_end_date,    [:notification_end_date, DateTime]],
      [:officer,                  [:officer, String]],
      [:estimated_cost,           [:estimated_cost, String]]
    ]

    # Mandatory parameters
    validates :dat_id, :development_type, :last_modified_date, :description,
      :authority, :lodgement_date, :determination_date, :status,
      presence_before_type_cast: {spec_section: "4.3.1"}
    # Other validations
    validates :last_modified_date, :lodgement_date,
      date_time: {spec_section: "4.3.8"}
    validates :determination_date, :notification_start_date,
      :notification_end_date, date_time_or_none: {spec_section: "4.3.1"}
    validate :notification_dates_consistent!

    def notification_dates_consistent!
      if notification_start_date_before_type_cast == "none" && notification_end_date_before_type_cast != "none"
        errors.add(:notification_start_date, ErrorMessage["can't be none unless notification_end_date is none as well", "4.3.1"])
      end
      if notification_start_date_before_type_cast != "none" && notification_end_date_before_type_cast == "none"
        errors.add(:notification_end_date, ErrorMessage["can't be none unless notification_start_date is none as well", "4.3.1"])
      end
      if notification_start_date_before_type_cast && notification_end_date_before_type_cast.blank?
        errors.add(:notification_end_date, ErrorMessage["can not be blank if notification_start_date is set", "4.3.1"])
      end
      if notification_start_date_before_type_cast.blank? && notification_end_date_before_type_cast
        errors.add(:notification_start_date, ErrorMessage["can not be blank if notification_end_date is set", "4.3.1"])
      end
      if notification_start_date && notification_end_date && notification_start_date > notification_end_date
        errors.add(:notification_end_date, ErrorMessage["can not be earlier than notification_start_date", "4.3.1"])
      end
    end
  end
end
