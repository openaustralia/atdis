module ATDIS
  class Document < Model
    attr_accessor :ref, :title, :document_url

    def self.convert(data)
      data[:document_url] = URI.parse(data[:document_url]) if data[:document_url]
      data
    end
  end
end