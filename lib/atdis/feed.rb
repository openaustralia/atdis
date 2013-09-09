require "rest-client"

module ATDIS
  class Feed
    attr_reader :base_url

    # base_url - the base url from which the urls for all atdis urls are made
    # It is the concatenation of the protocol and web address as defined in section 4.2 of specification
    # For example if the base_url is "http://www.council.nsw.gov.au" then the url for listing all the
    # applications is "http://www.council.nsw.gov.au/atdis/1.0/applications.json"
    def initialize(base_url, page = 1)
      @base_url = base_url.kind_of?(URI) ? base_url : URI.parse(base_url)
      @page = page
    end

    def applications
      url = base_url + "atdis/1.0/applications.json"
      url += "?page=#{@page}" if @page > 1
      Page.read_url(url)
    end
  end
end
