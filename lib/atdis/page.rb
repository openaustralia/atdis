module ATDIS
  class Page < Model
    attr_accessor :url

    set_field_mappings [
      [:response, [:response, Application]],
      [:count, [:count, Fixnum]],
      [:pagination, [
        [:previous, [:previous, Fixnum]],
        [:next, [:next, Fixnum]],
        [:current, [:current_page_no, Fixnum]],
        [:per_page, [:no_results_per_page, Fixnum]],
        [:count, [:total_no_results, Fixnum]],
        [:pages, [:total_no_pages, Fixnum]]
      ]]
    ]

    # Mandatory parameters
    validates :response, presence_before_type_cast: {spec_section: "4.3"}
    validates :response, valid: true
    # section 6.5 is not explicitly about this but it does contain an example which should be helpful
    validates :response, array: {spec_section: "6.5"}
    validate :count_is_consistent, :all_pagination_is_present, :previous_is_consistent, :next_is_consistent
    validate :current_page_no_is_consistent, :total_no_results_is_consistent
    validate :json_loaded_correctly!

    def json_loaded_correctly!
      if json_load_error
        errors.add(:json, ErrorMessage["Invalid JSON: #{json_load_error}", nil])
      end
    end

    # If some of the pagination fields are present all of the required ones should be present
    def all_pagination_is_present
      if count || previous || self.next || current_page_no || no_results_per_page ||
        total_no_results || total_no_pages
        errors.add(:count, ErrorMessage["should be present if pagination is being used", "6.5"]) if count.nil?
        errors.add(:current_page_no, ErrorMessage["should be present if pagination is being used", "6.5"]) if current_page_no.nil?
        errors.add(:no_results_per_page, ErrorMessage["should be present if pagination is being used", "6.5"]) if no_results_per_page.nil?
        errors.add(:total_no_results, ErrorMessage["should be present if pagination is being used", "6.5"]) if total_no_results.nil?
        errors.add(:total_no_pages, ErrorMessage["should be present if pagination is being used", "6.5"]) if total_no_pages.nil?
      end
    end

    def count_is_consistent
      if count
        errors.add(:count, ErrorMessage["is not the same as the number of applications returned", "6.5"]) if count != response.count
        errors.add(:count, ErrorMessage["should not be larger than the number of results per page", "6.5"]) if count > no_results_per_page
      end
    end

    def previous_is_consistent
      if current_page_no
        if previous
          if previous != current_page_no - 1
            errors.add(:previous, ErrorMessage["should be one less than current page number or null if first page", "6.5"])
          end
          if current_page_no == 1
            errors.add(:previous, ErrorMessage["should be null if on the first page", "6.5"])
          end
        else
          if current_page_no > 1
            errors.add(:previous, ErrorMessage["can't be null if not on the first page", "6.5"])
          end
        end
      end
    end

    def next_is_consistent
      if self.next && self.next != current_page_no + 1
        errors.add(:next, ErrorMessage["should be one greater than current page number or null if last page", "6.5"])
      end
      if self.next.nil? && current_page_no != total_no_pages
        errors.add(:next, ErrorMessage["can't be null if not on the last page", "6.5"])
      end
      if self.next && current_page_no == total_no_pages
        errors.add(:next, ErrorMessage["should be null if on the last page", "6.5"])
      end
    end

    def current_page_no_is_consistent
      if current_page_no
        errors.add(:current_page_no, ErrorMessage["is larger than the number of pages", "6.5"]) if current_page_no > total_no_pages
        errors.add(:current_page_no, ErrorMessage["can not be less than 1", "6.5"]) if current_page_no < 1
      end
    end

    def total_no_results_is_consistent
      if total_no_pages && total_no_results > total_no_pages * no_results_per_page
        errors.add(:total_no_results, ErrorMessage["is larger than can be retrieved through paging", "6.5"])
      end
      if total_no_pages && total_no_results <= (total_no_pages - 1) * no_results_per_page
        errors.add(:total_no_results, ErrorMessage["could fit into a smaller number of pages", "6.5"])
      end
    end

    def self.read_url(url)
      r = read_json(RestClient.get(url.to_s).to_str)
      r.url = url.to_s
      r
    end

    def self.read_json(text)
      begin
        data = MultiJson.load(text, symbolize_keys: true)
        interpret(data)
      rescue MultiJson::LoadError => e
        a = interpret({response: []})
        a.json_load_error = e.to_s
        a
      end
    end

    def previous_url
      raise "Can't use previous_url when loaded with read_json" if url.nil?
      ATDIS::SeparatedURL.merge(url, page: previous) if previous
    end

    def next_url
      raise "Can't use next_url when loaded with read_json" if url.nil?
      ATDIS::SeparatedURL.merge(url, page: self.next) if self.next
    end

    def previous_page
      Page.read_url(previous_url) if previous_url
    end

    def next_page
      Page.read_url(next_url) if next_url
    end
  end
end
