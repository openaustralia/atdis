# frozen_string_literal: true

require "atdis/models/response"
require "atdis/models/pagination"

module ATDIS
  module Models
    class Page < Model
      field_mappings(
        response: Response,
        count: Fixnum,
        pagination: Pagination
      )

      # Mandatory parameters
      validates :response, presence_before_type_cast: { spec_section: "4.3" }
      # section 6.5 is not explicitly about this but it does contain an example which should be helpful
      validates :response, array: { spec_section: "6.4" }
      validate :count_is_consistent, :all_pagination_is_present

      # This model is only valid if the children are valid
      validates :response, valid: true
      validates :pagination, valid: true

      # If some of the pagination fields are present all of the required ones should be present
      def all_pagination_is_present
        return unless pagination && count.nil?

        errors.add(:count, ErrorMessage["should be present if pagination is being used", "6.4"])
      end

      def count_is_consistent
        return if count.nil?

        if response.respond_to?(:count)
          errors.add(:count, ErrorMessage["is not the same as the number of applications returned", "6.4"]) if count != response.count
        end
        return unless pagination.respond_to?(:per_page) && pagination.per_page

        errors.add(:count, ErrorMessage["should not be larger than the number of results per page", "6.4"]) if count > pagination.per_page
      end

      def previous_url
        raise "Can't use previous_url when loaded with read_json" if url.nil?

        ATDIS::SeparatedURL.merge(url, page: pagination.previous) if pagination&.previous
      end

      def next_url
        raise "Can't use next_url when loaded with read_json" if url.nil?

        ATDIS::SeparatedURL.merge(url, page: pagination.next) if pagination&.next
      end

      def previous_page
        Page.read_url(previous_url) if previous_url
      end

      def next_page
        Page.read_url(next_url) if next_url
      end
    end
  end
end
