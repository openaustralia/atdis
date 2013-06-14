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

  class ApplicationsResults
    attr_accessor :url, :previous_page_no, :next_page_no, :current_page_no, :no_results_per_page,
      :total_no_results, :total_no_pages, :results

    def self.read(u)
      r = RestClient.get(u.full_url)
      json_data = MultiJson.load(r.to_str, :symbolize_keys => true)

      interpret(u, json_data)      
    end

    def self.interpret(u, json_data)
      results = ApplicationsResults.new
      results.url = u

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

    def next
      ApplicationsResults.read(url.merge(:page => next_page_no)) if next_page_no
    end
  end
end
