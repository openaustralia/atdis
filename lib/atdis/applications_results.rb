module ATDIS
  class ApplicationsResults
    def initialize(url, url_params = {})
      @url, @url_params = url, url_params
      r = RestClient.get(full_url)
      @json_data = MultiJson.load(r.to_str, :symbolize_keys => true)
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
      @json_data[:response].map {|a| Application.interpret(a[:application]) }
    end

    def next
      ApplicationsResults.new(@url, @url_params.merge(:page => next_page_no)) if next_page_no
    end

    def previous_page_no
      @json_data[:pagination][:previous] if @json_data[:pagination]
    end

    def next_page_no
      @json_data[:pagination][:next] if @json_data[:pagination]
    end

    def current_page_no
      @json_data[:pagination][:current] if @json_data[:pagination]
    end

    def no_results_per_page
      @json_data[:pagination][:per_page] if @json_data[:pagination]
    end

    def total_no_results
      @json_data[:pagination][:count] if @json_data[:pagination]
    end

    def total_no_pages
      @json_data[:pagination][:pages] if @json_data[:pagination]
    end
  end
end
