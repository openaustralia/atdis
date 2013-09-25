require "rest-client"

module ATDIS
  class Feed
    attr_reader :base_url

    # base_url - the base url from which the urls for all atdis urls are made
    # It should be of the form:
    # http://www.council.nsw.gov.au/atdis/1.0/applications.json
    def initialize(base_url)
      @base_url = base_url
    end

    def url(options = {})
      valid_options = [:page, :postcode, :lodgement_date_start, :lodgement_date_end, :last_modified_date_start, :last_modified_date_end]
      invalid_options = options.keys - valid_options
      if !invalid_options.empty?
        raise "Unexpected options used: #{invalid_options.join(',')}"
      end
      options[:postcode] = options[:postcode].join(",") if options[:postcode].respond_to?(:join)

      url = base_url
      unless options.empty?
        url += "?" + options.sort{|a,b| a.first.to_s <=> b.first.to_s}.map{|k,v| "#{k}=#{v}"}.join("&")
      end
      url
    end

    def self.base_url_from_url(url)
      u = URI.parse(url)
      u.query = nil
      u.fragment = nil
      u.to_s
    end

    def self.options_from_url(url)
      u = URI.parse(url)
      options = {}
      if u.query
        u.query.split("&").each do |t|
          key, value = t.split("=")
          options[key.to_sym] = value
        end
      end
      [:lodgement_date_start, :lodgement_date_end, :last_modified_date_start, :last_modified_date_end].each do |k|
        options[k] = Date.parse(options[k]) if options[k]
      end
      options[:page] = options[:page].to_i if options[:page]
      options
    end

    def applications(options = {})
      Page.read_url(url(options))
    end
  end
end
