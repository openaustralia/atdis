module ATDIS
  class SeparatedURL
    attr_accessor :full_url

    def initialize(full_url)
      @full_url = full_url
    end

    def self.full_url(url, url_params)
      # Doing this jiggery pokery to ensure the params are sorted alphabetically (even on Ruby 1.8)
      query = url_params.map{|k,v| [k.to_s, v]}.sort.map{|k,v| "#{CGI.escape(k)}=#{CGI.escape(v.to_s)}"}.join("&")
      if url_params.empty?
        url
      else
        url + "?" + query
      end
    end

    def merge(params)
      uri = URI.parse(full_url)
      url = "#{uri.scheme}://#{uri.host}#{uri.path}"
      if uri.query
        url_params = Hash[*CGI::parse(uri.query).map{|k,v| [k.to_sym,v.first]}.flatten]
      else
        url_params = {}
      end
      SeparatedURL.new(SeparatedURL.full_url(url, url_params.merge(params)))
    end

    def ==(other)
      full_url == other.full_url 
    end
  end
end
