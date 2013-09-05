module ATDIS
  class Page < Model
    attr_accessor :url, :previous_page_no, :next_page_no, :current_page_no, :no_results_per_page,
      :total_no_results, :total_no_pages, :results

    Page.valid_fields = {
      :response => :results,
      :pagination => {
        :previous => :previous_page_no,
        :next => :next_page_no,
        :current => :current_page_no,
        :per_page => :no_results_per_page,
        :count => :total_no_results,
        :pages => :total_no_pages
      }
    }

    def self.read_url(url)
      r = read_json(RestClient.get(url.to_s).to_str)
      r.url = url.to_s
      r
    end

    def self.read_json(text)
      interpret(MultiJson.load(text, :symbolize_keys => true))
    end

    def results=(v)
      # TODO Would be more consistent if we called Application.interpret(a)
      @results = v.map {|a| Application.interpret(a[:application]) }
    end

    def next
      raise "Can't use next when loaded with read_json" if url.nil?
      Page.read_url(ATDIS::SeparatedURL.merge(url, :page => next_page_no)) if next_page_no
    end
  end
end
