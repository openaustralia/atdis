module ATDIS
  class ApplicationsResults
    def initialize(url, url_params = {})
      @url, @url_params = url, url_params
    end

    def full_url
      # TODO Correctly encode url_params
      query = @url_params.map{|k,v| "#{k}=#{v}"}.join("&")
      if @url_params.empty?
        @url
      else
        @url + "?" + query
      end
    end

    def results
      r = RestClient.get(full_url)
      json_data = MultiJson.load(r.to_str, :symbolize_keys => true)
      json_data[:response].map {|a| Application.interpret(a[:application]) }
    end

    def next
    end
  end
end
