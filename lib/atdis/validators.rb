require 'active_model'

module ATDIS
  module Validators
    class GeoJsonValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        raw_value = record.send("#{attribute}_before_type_cast")
        if raw_value.present? && value.nil?
          record.errors.add(attribute, "is not valid GeoJSON")
        end
      end
    end

    class DateTimeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        raw_value = record.send("#{attribute}_before_type_cast")
        if raw_value.present? && !value.kind_of?(DateTime)
          record.errors.add(attribute, "is not a valid date")
        end
      end
    end

    class DateTimeOrNoneValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        raw_value = record.send("#{attribute}_before_type_cast")
        if raw_value.present? && raw_value != "none" && !value.kind_of?(DateTime)
          record.errors.add(attribute, "is not a valid date or none")
        end
      end
    end

    class HttpUrlValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        raw_value = record.send("#{attribute}_before_type_cast")
        if raw_value.present? && !value.kind_of?(URI::HTTP) && !value.kind_of?(URI::HTTPS) 
          record.errors.add(attribute, "is not a valid URL")
        end
      end
    end

    # Take into account the value before type casting
    class PresenceBeforeTypeCastValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        raw_value = record.send("#{attribute}_before_type_cast")
        unless raw_value.present?
          record.errors.add(attribute, "can't be blank")
        end
      end
    end

    # This attribute itself needs to be valid
    class ValidValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if (value.respond_to?(:valid?) && !value.valid?) || (value && !value.respond_to?(:valid?) && !value.all?{|v| v.valid?})
          record.errors.add(attribute, "is not valid")
        end
      end
    end
  end
end
