require "rest-client"

module ATDIS
  class Applications
    attr_reader :base_url

    # base_url - the base url from which the urls for all atdis urls are made
    # It is the concatenation of the protocol and web address as defined in section 4.2 of specification
    # For example if the base_url is "http://www.council.nsw.gov.au" then the url for listing all the
    # applications is "http://www.council.nsw.gov.au/atdis/1.0/applications.json"
    def initialize(base_url)
      @base_url = base_url.kind_of?(URI) ? base_url : URI.parse(base_url)
    end

    def all
      # TODO: Use URL to do the concatenation
      url = base_url + "/" + "atdis/1.0/applications.json"
      r = RestClient.get(url)
      json_string = r.to_str
      json_data = MultiJson.load(json_string, :symbolize_keys => true)
      ApplicationsResults.new(json_data[:response].map {|a| Application.interpret(a[:application]) })
    end
  end
end
