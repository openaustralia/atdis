require 'active_model'

module ATDIS
  module Validators
    class GeoJsonValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        raw_value = record.send("#{attribute}_before_type_cast")
        if raw_value.present? && value.nil?
          message = "is not valid GeoJSON"
          message = ErrorMessage[message, options[:spec_section]] if options[:spec_section]
          record.errors.add(attribute, message)
        end
      end
    end

    class DateTimeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        raw_value = record.send("#{attribute}_before_type_cast")
        if raw_value.present? && !value.kind_of?(DateTime)
          record.errors.add(attribute, ErrorMessage["is not a valid date", options[:spec_section]])
        end
      end
    end

    class DateTimeOrNoneValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        raw_value = record.send("#{attribute}_before_type_cast")
        if raw_value.present? && raw_value != "none" && !value.kind_of?(DateTime)
          message = "is not a valid date or none"
          message = ErrorMessage[message, options[:spec_section]] if options[:spec_section]
          record.errors.add(attribute, message)
        end
      end
    end

    class HttpUrlValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        raw_value = record.send("#{attribute}_before_type_cast")
        if raw_value.present? && !value.kind_of?(URI::HTTP) && !value.kind_of?(URI::HTTPS) 
          message = "is not a valid URL"
          message = ErrorMessage[message, options[:spec_section]] if options[:spec_section]
          record.errors.add(attribute, message)
        end
      end
    end

    class ArrayValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value && !value.kind_of?(Array)
          message = "should be an array"
          message = ErrorMessage[message, options[:spec_section]] if options[:spec_section]
          record.errors.add(attribute, message)
        end
      end
    end

    # Take into account the value before type casting
    class PresenceBeforeTypeCastValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        raw_value = record.send("#{attribute}_before_type_cast")
        if !raw_value.kind_of?(Array) && !raw_value.present?
          message = "can't be blank"          
          message = ErrorMessage[message, options[:spec_section]] if options[:spec_section]
          record.errors.add(attribute, message)
        end
      end
    end

    # This attribute itself needs to be valid
    class ValidValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if (value.respond_to?(:valid?) && !value.valid?) || (value && !value.respond_to?(:valid?) && !value.all?{|v| v.valid?})
          record.errors.add(attribute, ErrorMessage["is not valid", nil])
        end
      end
    end
  end
end
