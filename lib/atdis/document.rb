module ATDIS
  class Document < Model
    define_attribute_methods ['document_url']

    def attribute_types
      {
        'document_url' => URI
      }
    end

    attr_accessor :ref, :title
  end
end