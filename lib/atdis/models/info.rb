require "atdis/models/authority"

module ATDIS
  module Models
    class Info < Model
      set_field_mappings ({
        dat_id:                  String,
        development_type:        String,
        application_type:        String,
        last_modified_date:      DateTime,
        description:             String,
        authority:               Authority,
        lodgement_date:          DateTime,
        determination_date:      DateTime,
        determination_type:      String,
        status:                  String,
        notification_start_date: DateTime,
        notification_end_date:   DateTime,
        officer:                 String,
        estimated_cost:          String,
        related_apps:            URI
      })

      # Mandatory parameters
      # determination_date is not in this list because even though it is mandatory
      # it can be null if there is no value
      validates :dat_id, :development_type, :last_modified_date, :description,
        :authority, :lodgement_date, :status,
        presence_before_type_cast: {spec_section: "4.3.1"}
      # Other validations
      validates :application_type, inclusion: { in: [
        "DA", "CDC", "S96", "Review", "Appeal", "Other"
        ],
        message: ATDIS::ErrorMessage.new("does not have one of the allowed types", "4.3.1")}
      validates :last_modified_date, :lodgement_date, :determination_date,
        :notification_start_date, :notification_end_date,
        date_time: {spec_section: "4.3.1"}
      # We don't need to separately validate presence because this covers it
      validates :determination_type, inclusion: { in: [
        "Pending", "Refused by Council", "Refused under delegation", "Withdrawn",
        "Approved by Council", "Approved under delegation", "Rejected"
        ],
        message: ATDIS::ErrorMessage.new("does not have one of the allowed types", "4.3.1")
      }
      validate :notification_dates_consistent!
      validates :related_apps, array: {spec_section: "4.3.1"}
      validates :related_apps, array_http_url: {spec_section: "4.3.1"}
      validate :related_apps_url_format

      # This model is only valid if the children are valid
      validates :authority, valid: true

      def related_apps_url_format
        if related_apps.respond_to?(:all?) && !related_apps.all? {|url| url.to_s =~ /atdis\/1.0\/[^\/]+\.json/}
          errors.add(:related_apps, ErrorMessage.new("contains url(s) not in the expected format", "4.3.1"))
        end
      end

      def notification_dates_consistent!
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
end
