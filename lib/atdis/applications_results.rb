module ATDIS
  class ApplicationsResults
    attr_reader :previous_page_no, :next_page_no, :current_page_no, :no_results_per_page,
      :total_no_results, :total_no_pages

    def initialize(url, url_params = {})
      @url, @url_params = url, url_params
      r = RestClient.get(full_url)
      @json_data = MultiJson.load(r.to_str, :symbolize_keys => true)

      if @json_data[:pagination]
        @previous_page_no = @json_data[:pagination][:previous]
        @next_page_no = @json_data[:pagination][:next]
        @current_page_no = @json_data[:pagination][:current]
        @no_results_per_page = @json_data[:pagination][:per_page]
        @total_no_results = @json_data[:pagination][:count]
        @total_no_pages = @json_data[:pagination][:pages]
      end
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
  end
end
