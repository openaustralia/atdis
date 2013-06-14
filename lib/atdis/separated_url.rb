module ATDIS
  class SeparatedURL
    attr_accessor :url, :url_params

    def initialize(url, url_params = {})
      @url, @url_params = url, url_params
    end

    def full_url
      # TODO Correctly encode url_params
      query = url_params.map{|k,v| "#{k}=#{v}"}.join("&")
      if url_params.empty?
        url
      else
        url + "?" + query
      end
    end

    def merge(params)
      SeparatedURL.new(url, url_params.merge(params))
    end

    def ==(other)
      url == other.url && url_params == other.url_params
    end
  end
end
