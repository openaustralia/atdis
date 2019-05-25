# frozen_string_literal: true

module ATDIS
  module Models
    class Pagination < Model
      field_mappings(
        previous: Fixnum,
        next: Fixnum,
        current: Fixnum,
        per_page: Fixnum,
        count: Fixnum,
        pages: Fixnum
      )

      validate :all_pagination_is_present, :previous_is_consistent,
               :next_is_consistent, :current_is_consistent,
               :count_is_consistent

      # If some of the pagination fields are present all of the required ones should be present
      def all_pagination_is_present
        errors.add(:current, ErrorMessage["should be present if pagination is being used", "6.4"]) if current.nil?
        errors.add(:per_page, ErrorMessage["should be present if pagination is being used", "6.4"]) if per_page.nil?
        errors.add(:count, ErrorMessage["should be present if pagination is being used", "6.4"]) if count.nil?
        errors.add(:pages, ErrorMessage["should be present if pagination is being used", "6.4"]) if pages.nil?
      end

      def previous_is_consistent
        errors.add(:previous, ErrorMessage["should be one less than current page number or null if first page", "6.4"]) if previous && current && previous != current - 1
        errors.add(:previous, ErrorMessage["should be null if on the first page", "6.4"]) if previous && current && current == 1
        return unless previous.nil? && current && current > 1

        errors.add(:previous, ErrorMessage["can't be null if not on the first page", "6.4"])
      end

      def next_is_consistent
        errors.add(:next, ErrorMessage["should be one greater than current page number or null if last page", "6.4"]) if self.next && current && self.next != current + 1
        errors.add(:next, ErrorMessage["can't be null if not on the last page", "6.4"]) if self.next.nil? && current != pages
        return unless self.next && current == pages

        errors.add(:next, ErrorMessage["should be null if on the last page", "6.4"])
      end

      def current_is_consistent
        errors.add(:current, ErrorMessage["is larger than the number of pages", "6.4"]) if current && pages && current > pages
        return unless current && current < 1

        errors.add(:current, ErrorMessage["can not be less than 1", "6.4"])
      end

      def count_is_consistent
        errors.add(:count, ErrorMessage["is larger than can be retrieved through paging", "6.4"]) if pages && per_page && count && count > pages * per_page
        return unless pages && per_page && count && count.positive? && count <= (pages - 1) * per_page

        errors.add(:count, ErrorMessage["could fit into a smaller number of pages", "6.4"])
      end
    end
  end
end
