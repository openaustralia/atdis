module ATDIS
  class SeparatedURL

    def self.merge(full_url, params)
      url, url_params = split(full_url)
      combine(url, url_params.merge(params))
    end

    private
    
    def self.combine(url, url_params)
      # Doing this jiggery pokery to ensure the params are sorted alphabetically (even on Ruby 1.8)
      query = url_params.map{|k,v| [k.to_s, v]}.sort.map{|k,v| "#{CGI.escape(k)}=#{CGI.escape(v.to_s)}"}.join("&")
      if url_params.empty?
        url
      else
        url + "?" + query
      end
    end

    def self.split(full_url)
      uri = URI.parse(full_url)
      url = "#{uri.scheme}://#{uri.host}#{uri.path}"
      if uri.query
        url_params = Hash[*CGI::parse(uri.query).map{|k,v| [k.to_sym,v.first]}.flatten]
      else
        url_params = {}
      end
      [url, url_params]
    end

  end
end
