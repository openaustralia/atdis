module ATDIS
  class ApplicationsResults
    attr_accessor :url, :url_params, :previous_page_no, :next_page_no, :current_page_no, :no_results_per_page,
      :total_no_results, :total_no_pages, :results

    def self.read(url, url_params = {})
      r = RestClient.get(full_url(url, url_params))
      json_data = MultiJson.load(r.to_str, :symbolize_keys => true)

      interpret(url, url_params, json_data)
    end

    def self.interpret(url, url_params, json_data)
      results = ApplicationsResults.new

      results.url = url
      results.url_params = url_params

      results.results = json_data[:response].map {|a| Application.interpret(a[:application]) }
      if json_data[:pagination]
        results.previous_page_no = json_data[:pagination][:previous]
        results.next_page_no = json_data[:pagination][:next]
        results.current_page_no = json_data[:pagination][:current]
        results.no_results_per_page = json_data[:pagination][:per_page]
        results.total_no_results = json_data[:pagination][:count]
        results.total_no_pages = json_data[:pagination][:pages]
      end

      results      
    end

    def self.full_url(url, url_params)
      # TODO Correctly encode url_params
      query = url_params.map{|k,v| "#{k}=#{v}"}.join("&")
      if url_params.empty?
        url
      else
        url + "?" + query
      end
    end

    def next
      ApplicationsResults.read(@url, @url_params.merge(:page => next_page_no)) if next_page_no
    end
  end
end
