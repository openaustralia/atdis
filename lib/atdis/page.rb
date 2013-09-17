module ATDIS
  class Page < Model
    attr_accessor :url

    field_mappings [
      [:response, [:results, Application, {:level => 1}]],
      [:count, [:count, Fixnum, {:level => 2}]],
      [:pagination, [
        [:previous, [:previous_page_no, Fixnum, {:level => 2}]],
        [:next, [:next_page_no, Fixnum, {:level => 2}]],
        [:current, [:current_page_no, Fixnum, {:level => 2}]],
        [:per_page, [:no_results_per_page, Fixnum, {:level => 2}]],
        [:count, [:total_no_results, Fixnum, {:level => 2}]],
        [:pages, [:total_no_pages, Fixnum, {:level => 2}]]
      ]]
    ]

    # Mandatory parameters
    validates :results, :presence_before_type_cast => true
    validates :results, :valid => true
    validate :count_is_consistent, :all_pagination_is_present, :previous_page_no_is_consistent, :next_page_no_is_consistent
    validate :current_page_no_is_consistent, :total_no_results_is_consistent

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
      if count
        errors.add(:count, "is not the same as the number of applications returned") if count != results.count        
        errors.add(:count, "should not be larger than the number of results per page") if count > no_results_per_page
      end
    end

    # Have we tried to use this attribute?
    def used_attribute?(a)
      !attributes_before_type_cast[a].blank?
    end

    # Whether we have used any attributes that are L1
    def L1_used?
      Page.level_attribute_names(1).any?{|a| used_attribute?(a)}
    end

    def level_used_locally?(level)
      Page.level_attribute_names(level).any?{|a| used_attribute?(a)}
    end

    def L2_used_locally?
      level_used_locally?(2)
    end

    def L2_used_in_children?
      attributes.each_value do |a|
        if a.respond_to?(:level_used?) && a.level_used?(2)
          return true
        elsif !a.respond_to?(:level_used?) && a.respond_to?(:any?) && a.any?{|b| b.level_used?(2)}
          return true
        end
      end
      false
    end

    def L2_used?
      L2_used_locally? || L2_used_in_children?
    end

    def previous_page_no_is_consistent
      if current_page_no
        if previous_page_no
          if previous_page_no != current_page_no - 1
            errors.add(:previous_page_no, "should be one less than current page number or null if first page")
          end
          if current_page_no == 1
            errors.add(:previous_page_no, "should be null if on the first page")
          end            
        else
          if current_page_no > 1
            errors.add(:previous_page_no, "can't be null if not on the first page")
          end
        end
      end 
    end

    def next_page_no_is_consistent
      if next_page_no && next_page_no != current_page_no + 1
        errors.add(:next_page_no, "should be one greater than current page number or null if last page")
      end
      if next_page_no.nil? && current_page_no != total_no_pages
        errors.add(:next_page_no, "can't be null if not on the last page")
      end
      if next_page_no && current_page_no == total_no_pages
        errors.add(:next_page_no, "should be null if on the last page")
      end
    end

    def current_page_no_is_consistent
      if current_page_no
        errors.add(:current_page_no, "is larger than the number of pages") if current_page_no > total_no_pages        
        errors.add(:current_page_no, "can not be less than 1") if current_page_no < 1
      end
    end

    def total_no_results_is_consistent
      if total_no_pages && total_no_results > total_no_pages * no_results_per_page
        errors.add(:total_no_results, "is larger than can be retrieved through paging")
      end
      if total_no_pages && total_no_results <= (total_no_pages - 1) * no_results_per_page
        errors.add(:total_no_results, "could fit into a smaller number of pages")
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

    def previous_url
      raise "Can't use previous_url when loaded with read_json" if url.nil?
      ATDIS::SeparatedURL.merge(url, :page => previous_page_no) if previous_page_no
    end

    def next_url
      raise "Can't use next_url when loaded with read_json" if url.nil?
      ATDIS::SeparatedURL.merge(url, :page => next_page_no) if next_page_no
    end

    def previous
      Page.read_url(previous_url) if previous_url
    end

    def next
      Page.read_url(next_url) if next_url
    end
  end
end
