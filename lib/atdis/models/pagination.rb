# frozen_string_literal: true

module ATDIS
  module Models
    class Pagination < Model
      field_mappings(
        previous: Integer,
        next: Integer,
        current: Integer,
        per_page: Integer,
        count: Integer,
        pages: Integer
      )

      validate :all_pagination_is_present, :previous_is_consistent,
               :next_is_consistent, :current_is_consistent,
               :count_is_consistent

      # If some of the pagination fields are present all of the required ones should be present
      def all_pagination_is_present
        if current.nil?
          errors.add(
            :current,
            ErrorMessage["should be present if pagination is being used", "6.4"]
          )
        end
        if per_page.nil?
          errors.add(
            :per_page,
            ErrorMessage["should be present if pagination is being used", "6.4"]
          )
        end
        if count.nil?
          errors.add(
            :count,
            ErrorMessage["should be present if pagination is being used", "6.4"]
          )
        end
        return unless pages.nil?

        errors.add(
          :pages,
          ErrorMessage["should be present if pagination is being used", "6.4"]
        )
      end

      def previous_is_consistent
        if previous && current && previous != current - 1
          errors.add(
            :previous,
            ErrorMessage["should be one less than current page number or null if first page", "6.4"]
          )
        end
        if previous && current && current == 1
          errors.add(
            :previous,
            ErrorMessage["should be null if on the first page", "6.4"]
          )
        end
        return unless previous.nil? && current && current > 1

        errors.add(
          :previous,
          ErrorMessage["can't be null if not on the first page", "6.4"]
        )
      end

      def next_is_consistent
        if self.next && current && self.next != current + 1
          errors.add(
            :next,
            ErrorMessage[
              "should be one greater than current page number or null if last page",
              "6.4"
            ]
          )
        end
        if self.next.nil? && current != pages
          errors.add(
            :next,
            ErrorMessage["can't be null if not on the last page", "6.4"]
          )
        end
        return unless self.next && current == pages

        errors.add(
          :next,
          ErrorMessage["should be null if on the last page", "6.4"]
        )
      end

      def current_is_consistent
        if current && pages && current > pages
          errors.add(
            :current,
            ErrorMessage["is larger than the number of pages", "6.4"]
          )
        end
        return unless current && current < 1

        errors.add(
          :current,
          ErrorMessage["can not be less than 1", "6.4"]
        )
      end

      def count_is_consistent
        if pages && per_page && count && count > pages * per_page
          errors.add(
            :count,
            ErrorMessage["is larger than can be retrieved through paging", "6.4"]
          )
        end
        return unless pages &&
                      per_page &&
                      count &&
                      count.positive? &&
                      count <= (pages - 1) * per_page

        errors.add(
          :count,
          ErrorMessage["could fit into a smaller number of pages", "6.4"]
        )
      end
    end
  end
end
