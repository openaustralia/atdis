require "rest-client"

module ATDIS
  class Feed
    attr_reader :base_url

    # base_url - the base url from which the urls for all atdis urls are made
    # It should be of the form:
    # http://www.council.nsw.gov.au/atdis/1.0/applications.json
    def initialize(base_url)
      @base_url = base_url.kind_of?(URI) ? base_url : URI.parse(base_url)
    end

    def applications(page = 1)
      url = base_url
      url += "?page=#{page}" if page > 1
      Page.read_url(url)
    end
  end
end
