module ATDIS
  class Page < Model
    attr_accessor :url

    field_mappings :response => :results,
      :pagination => {
        :previous => :previous_page_no,
        :next => :next_page_no,
        :current => :current_page_no,
        :per_page => :no_results_per_page,
        :count => :total_no_results,
        :pages => :total_no_pages
      }
    casting_attributes :results => Application,
      :previous_page_no => Fixnum,
      :next_page_no => Fixnum,
      :current_page_no => Fixnum,
      :no_results_per_page => Fixnum,
      :total_no_results => Fixnum,
      :total_no_pages => Fixnum

    def self.read_url(url)
      r = read_json(RestClient.get(url.to_s).to_str)
      r.url = url.to_s
      r
    end

    def self.read_json(text)
      interpret(MultiJson.load(text, :symbolize_keys => true))
    end

    def next
      raise "Can't use next when loaded with read_json" if url.nil?
      Page.read_url(ATDIS::SeparatedURL.merge(url, :page => next_page_no)) if next_page_no
    end
  end
end
