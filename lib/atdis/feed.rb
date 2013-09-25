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

    # Always return the first page. We can use the in-built paging from Page to return
    # the following pages
    def applications(options = {})
      url = base_url
      if options[:postcode]
        postcode = options[:postcode]
        postcode = postcode.join(",") if postcode.respond_to?(:join)
        url += "?postcode=#{postcode}"
      end
      if options[:lodgement_date_start]
        url += "?lodgement_date_start=#{options[:lodgement_date_start]}"
      end
      if options[:lodgement_date_end]
        url += "&lodgement_date_end=#{options[:lodgement_date_end]}"
      end
      Page.read_url(url)
    end
  end
end
