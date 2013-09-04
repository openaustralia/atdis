module ATDIS
  class Page < Model
    attr_accessor :url, :previous_page_no, :next_page_no, :current_page_no, :no_results_per_page,
      :total_no_results, :total_no_pages, :results

    def self.read_url(url)
      r = read_json(RestClient.get(url.to_s).to_str)
      r.url = url.to_s
      r
    end

    def self.read_json(text)
      interpret(MultiJson.load(text, :symbolize_keys => true))
    end

    def self.convert(json_data)
      values = {
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
      [values, []]
    end

    def next
      raise "Can't use next when loaded with read_json" if url.nil?
      Page.read_url(ATDIS::SeparatedURL.merge(url, :page => next_page_no)) if next_page_no
    end
  end
end
