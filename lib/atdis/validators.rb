# frozen_string_literal: true

require "active_model"

module ATDIS
  module Validators
    class GeoJsonValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        raw_value = record.send("#{attribute}_before_type_cast")
        return unless raw_value.present? && value.nil?

        message = "is not valid GeoJSON"
        message = ErrorMessage[message, options[:spec_section]] if options[:spec_section]
        record.errors.add(attribute, message)
      end
    end

    class DateTimeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        raw_value = record.send("#{attribute}_before_type_cast")
        return unless raw_value.present? && !value.is_a?(DateTime)

        record.errors.add(attribute, ErrorMessage["is not a valid date", options[:spec_section]])
      end
    end

    class HttpUrlValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        raw_value = record.send("#{attribute}_before_type_cast")
        return unless raw_value.present? && !value.is_a?(URI::HTTP) && !value.is_a?(URI::HTTPS)

        message = "is not a valid URL"
        message = ErrorMessage[message, options[:spec_section]] if options[:spec_section]
        record.errors.add(attribute, message)
      end
    end

    class ArrayHttpUrlValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value.present? &&
           value.is_a?(Array) &&
           value.any? { |v| !v.is_a?(URI::HTTP) && !v.is_a?(URI::HTTPS) }
          message = "contains an invalid URL"
          message = ErrorMessage[message, options[:spec_section]] if options[:spec_section]
          record.errors.add(attribute, message)
        end
      end
    end

    class ArrayValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        return unless value && !value.is_a?(Array)

        message = "should be an array"
        message = ErrorMessage[message, options[:spec_section]] if options[:spec_section]
        record.errors.add(attribute, message)
      end
    end

    # Can't be an empty array
    class FilledArrayValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value && !value.is_a?(Array)
          message = "should be an array"
          message = ErrorMessage[message, options[:spec_section]] if options[:spec_section]
          record.errors.add(attribute, message)
        end
        return unless value&.is_a?(Array) && value&.empty?

        message = "should not be an empty array"
        message = ErrorMessage[message, options[:spec_section]] if options[:spec_section]
        record.errors.add(attribute, message)
      end
    end

    # Take into account the value before type casting
    class PresenceBeforeTypeCastValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, _value)
        raw_value = record.send("#{attribute}_before_type_cast")
        return unless !raw_value.is_a?(Array) && !raw_value.present?

        message = "can't be blank"
        message = ErrorMessage[message, options[:spec_section]] if options[:spec_section]
        record.errors.add(attribute, message)
      end
    end

    # This attribute itself needs to be valid
    class ValidValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        return unless (value.respond_to?(:valid?) && !value.valid?) ||
                      (value && !value.respond_to?(:valid?) && !value.all?(&:valid?))

        record.errors.add(
          attribute,
          ErrorMessage["is not valid (see further errors for details)", nil]
        )
      end
    end
  end
end
