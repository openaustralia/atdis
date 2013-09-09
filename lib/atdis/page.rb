module ATDIS
  class Page < Model
    attr_accessor :url

    field_mappings :response => [:results, Application],
      :count => [:count, Fixnum],
      :pagination => {
        :previous => [:previous_page_no, Fixnum],
        :next => [:next_page_no, Fixnum],
        :current => [:current_page_no, Fixnum],
        :per_page => [:no_results_per_page, Fixnum],
        :count => [:total_no_results, Fixnum],
        :pages => [:total_no_pages, Fixnum]
      }

    # Mandatory parameters
    validates :results, :presence_before_type_cast => true
    validates :results, :valid => true
    validate :count_is_consistent, :all_pagination_is_present

    # If some of the pagination fields are present all of the required ones should be present
    def all_pagination_is_present
      if count || previous_page_no || next_page_no || current_page_no || no_results_per_page ||
        total_no_results || total_no_pages
        errors.add(:count, "should be present if pagination is being used") if count.nil?
        errors.add(:current_page_no, "should be present if pagination is being used") if current_page_no.nil?
        errors.add(:no_results_per_page, "should be present if pagination is being used") if no_results_per_page.nil?
        errors.add(:total_no_results, "should be present if pagination is being used") if total_no_results.nil?
        errors.add(:total_no_pages, "should be present if pagination is being used") if total_no_pages.nil?
      end
    end

    def count_is_consistent
      if count && count != results.count
        errors.add(:count, "is not the same as the number of applications returned")
      end
    end

    def self.read_url(url)
      r = read_json(RestClient.get(url.to_s).to_str)
      r.url = url.to_s
      r
    end

    def self.read_json(text)
      interpret(MultiJson.load(text, :symbolize_keys => true))
    end

    def next
      raise "Can't use next when loaded with read_json" if url.nil?
      Page.read_url(ATDIS::SeparatedURL.merge(url, :page => next_page_no)) if next_page_no
    end
  end
end
