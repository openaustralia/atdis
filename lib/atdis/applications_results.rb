module ATDIS
  class ApplicationsResults < Model
    attr_accessor :url, :previous_page_no, :next_page_no, :current_page_no, :no_results_per_page,
      :total_no_results, :total_no_pages, :results

    def self.read(u)
      r = RestClient.get(u.full_url)
      json_data = MultiJson.load(r.to_str, :symbolize_keys => true)

      interpret(u, json_data)      
    end

    def self.convert(u, json_data)
      values = {
        :url => u,
        :results => json_data[:response].map {|a| Application.interpret(a[:application]) }
      }

      if json_data[:pagination]
        values[:previous_page_no] = json_data[:pagination][:previous]
        values[:next_page_no] = json_data[:pagination][:next]
        values[:current_page_no] = json_data[:pagination][:current]
        values[:no_results_per_page] = json_data[:pagination][:per_page]
        values[:total_no_results] = json_data[:pagination][:count]
        values[:total_no_pages] = json_data[:pagination][:pages]
      end
      values
    end

    def next
      ApplicationsResults.read(url.merge(:page => next_page_no)) if next_page_no
    end
  end
end
