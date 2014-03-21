require "atdis/models/response"
require "atdis/models/pagination"

module ATDIS
  module Models
    class Page < Model
      attr_accessor :url

      set_field_mappings ({
        response:   Response,
        count:      Fixnum,
        pagination: Pagination,
      })

      # Mandatory parameters
      validates :response, presence_before_type_cast: {spec_section: "4.3"}
      # section 6.5 is not explicitly about this but it does contain an example which should be helpful
      validates :response, array: {spec_section: "6.5"}
      validate :count_is_consistent, :all_pagination_is_present
      validate :json_loaded_correctly!

      # This model is only valid if the children are valid
      validates :response, valid: true
      validates :pagination, valid: true

      def json_loaded_correctly!
        if json_load_error
          errors.add(:json, ErrorMessage["Invalid JSON: #{json_load_error}", nil])
        end
      end

      # If some of the pagination fields are present all of the required ones should be present
      def all_pagination_is_present
        if pagination && count.nil?
          errors.add(:count, ErrorMessage["should be present if pagination is being used", "6.5"])
        end
      end

      def count_is_consistent
        if count
          errors.add(:count, ErrorMessage["is not the same as the number of applications returned", "6.5"]) if count != response.count
          errors.add(:count, ErrorMessage["should not be larger than the number of results per page", "6.5"]) if count > pagination.per_page
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
        ATDIS::SeparatedURL.merge(url, page: pagination.previous) if pagination
      end

      def next_url
        raise "Can't use next_url when loaded with read_json" if url.nil?
        ATDIS::SeparatedURL.merge(url, page: pagination.next) if pagination
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
