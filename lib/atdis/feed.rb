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
        url += "?postcode=#{options[:postcode]}"
      end
      Page.read_url(url)
    end
  end
end
