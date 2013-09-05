module ATDIS
  class Document < Model
    casting_attributes :document_url => URI

    attr_accessor :ref, :title

    Document.valid_fields = {
      :ref => :ref,
      :title => :title,
      :document_url => :document_url
    }    
  end
end