module ATDIS
  class Pagination < Model
    set_field_mappings [
      [:previous, [:previous, Fixnum]],
      [:next, [:next, Fixnum]],
      [:current, [:current, Fixnum]],
      [:per_page, [:per_page, Fixnum]],
      [:count, [:total_no_results, Fixnum]],
      [:pages, [:pages, Fixnum]]
    ]

    validate :all_pagination_is_present, :previous_is_consistent,
      :next_is_consistent, :current_is_consistent,
      :total_no_results_is_consistent

    # If some of the pagination fields are present all of the required ones should be present
    def all_pagination_is_present
      errors.add(:current, ErrorMessage["should be present if pagination is being used", "6.5"]) if current.nil?
      errors.add(:per_page, ErrorMessage["should be present if pagination is being used", "6.5"]) if per_page.nil?
      errors.add(:total_no_results, ErrorMessage["should be present if pagination is being used", "6.5"]) if total_no_results.nil?
      errors.add(:pages, ErrorMessage["should be present if pagination is being used", "6.5"]) if pages.nil?
    end

    def previous_is_consistent
      if previous && current && previous != current - 1
        errors.add(:previous, ErrorMessage["should be one less than current page number or null if first page", "6.5"])
      end
      if previous && current && current == 1
        errors.add(:previous, ErrorMessage["should be null if on the first page", "6.5"])
      end
      if previous.nil? && current && current > 1
        errors.add(:previous, ErrorMessage["can't be null if not on the first page", "6.5"])
      end
    end

    def next_is_consistent
      if self.next && current && self.next != current + 1
        errors.add(:next, ErrorMessage["should be one greater than current page number or null if last page", "6.5"])
      end
      if self.next.nil? && current != pages
        errors.add(:next, ErrorMessage["can't be null if not on the last page", "6.5"])
      end
      if self.next && current == pages
        errors.add(:next, ErrorMessage["should be null if on the last page", "6.5"])
      end
    end

    def current_is_consistent
      if current && pages && current > pages
        errors.add(:current, ErrorMessage["is larger than the number of pages", "6.5"])
      end
      if current && current < 1
        errors.add(:current, ErrorMessage["can not be less than 1", "6.5"])
      end
    end

    def total_no_results_is_consistent
      if pages && per_page && total_no_results && total_no_results > pages * per_page
        errors.add(:total_no_results, ErrorMessage["is larger than can be retrieved through paging", "6.5"])
      end
      if pages && per_page && total_no_results && total_no_results <= (pages - 1) * per_page
        errors.add(:total_no_results, ErrorMessage["could fit into a smaller number of pages", "6.5"])
      end
    end
  end
end
