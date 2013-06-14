module ATDIS
  class SeparatedURL
    attr_accessor :full_url

    def initialize(full_url)
      @full_url = full_url
    end

    def url
      SeparatedURL.parse_url(full_url)
    end

    def url_params
      SeparatedURL.parse_url_params(full_url)
    end

    def self.parse_url(full_url)
      uri = URI.parse(full_url)
      "#{uri.scheme}://#{uri.host}#{uri.path}"
    end

    def self.parse_url_params(full_url)
      uri = URI.parse(full_url)
      if uri.query
        Hash[*CGI::parse(uri.query).map{|k,v| [k.to_sym,v.first]}.flatten]
      else
        {}
      end
    end

    def self.parse(full_url)
      SeparatedURL.new(full_url)
    end

    def self.full_url(url, url_params)
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
      SeparatedURL.new(SeparatedURL.full_url(url, url_params.merge(params)))
    end

    def ==(other)
      url == other.url && url_params == other.url_params
    end
  end
end
