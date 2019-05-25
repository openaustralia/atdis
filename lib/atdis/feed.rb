require "rest-client"

module ATDIS
  class Feed
    attr_reader :base_url

    VALID_OPTIONS = %i[page street suburb postcode lodgement_date_start lodgement_date_end last_modified_date_start last_modified_date_end].freeze

    # base_url - the base url from which the urls for all atdis urls are made
    # It should be of the form:
    # http://www.council.nsw.gov.au/atdis/1.0
    def initialize(base_url)
      @base_url = base_url
    end

    def applications_url(options = {})
      invalid_options = options.keys - VALID_OPTIONS
      unless invalid_options.empty?
        raise "Unexpected options used: #{invalid_options.join(',')}"
      end
      options[:street] = options[:street].join(",") if options[:street].respond_to?(:join)
      options[:suburb] = options[:suburb].join(",") if options[:suburb].respond_to?(:join)
      options[:postcode] = options[:postcode].join(",") if options[:postcode].respond_to?(:join)

      q = Feed.options_to_query(options)
      "#{base_url}/applications.json" + (q ? "?#{q}" : "")
    end

    def application_url(id)
      "#{base_url}/#{CGI.escape(id)}.json"
    end

    def self.base_url_from_url(url)
      u = URI.parse(url)
      options = query_to_options(u.query)
      VALID_OPTIONS.each do |o|
        options.delete(o)
      end
      u.query = options_to_query(options)
      u.fragment = nil
      u.path = "/" + u.path.split("/")[1..-2].join("/")
      u.to_s
    end

    def self.options_from_url(url)
      u = URI.parse(url)
      options = query_to_options(u.query)
      %i[lodgement_date_start lodgement_date_end last_modified_date_start last_modified_date_end].each do |k|
        options[k] = Date.parse(options[k]) if options[k]
      end
      options[:page] = options[:page].to_i if options[:page]
      # Remove invalid options
      options.each_key do |key|
        options.delete(key) unless VALID_OPTIONS.include?(key)
      end
      options
    end

    def applications(options = {})
      Models::Page.read_url(applications_url(options))
    end

    def application(id)
      Models::Application.read_url(application_url(id))
    end

    # Turn a query string of the form "foo=bar&hello=sir" to {foo: "bar", hello: sir"}
    def self.query_to_options(query)
      options = {}
      if query
        query.split("&").each do |t|
          key, value = t.split("=")
          options[key.to_sym] = (CGI.unescape(value) if value)
        end
      end
      options
    end

    # Escape but leave commas unchanged (which are valid in query strings)
    def self.escape(v)
      CGI.escape(v.to_s).gsub("%2C", ",")
    end

    # Turn an options hash of the form {foo: "bar", hello: "sir"} into a query
    # string of the form "foo=bar&hello=sir"
    def self.options_to_query(options)
      if options.empty?
        nil
      else
        options.sort { |a, b| a.first.to_s <=> b.first.to_s }.map { |k, v| "#{k}=#{escape(v)}" }.join("&")
      end
    end
  end
end
