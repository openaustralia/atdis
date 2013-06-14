module ATDIS
  class SeparatedURL
    attr_accessor :url, :url_params

    def initialize(url, url_params = {})
      @url, @url_params = url, url_params
    end

    def full_url
      # TODO Correctly encode url_params
      # Doing this jiggery pokery to ensure the params are sorted alphabetically (even on Ruby 1.8)
      query = url_params.map{|k,v| [k.to_s, v]}.sort.map{|k,v| "#{k}=#{v}"}.join("&")
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
