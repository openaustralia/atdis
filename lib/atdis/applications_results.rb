module ATDIS
  class ApplicationsResults
    def initialize(url, url_params = {})
      @url, @url_params = url, url_params
    end

    def results
      # TODO Correctly encode url_params
      query = @url_params.map{|k,v| "#{k}=#{v}"}.join("&")
      if @url_params.empty?
        url = @url
      else
        url = @url + "?" + query
      end
      r = RestClient.get(url)
      json_data = MultiJson.load(r.to_str, :symbolize_keys => true)
      json_data[:response].map {|a| Application.interpret(a[:application]) }
    end

    def next
    end
  end
end
