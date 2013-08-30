module ATDIS
  class Document < Model
    casting_attributes :document_url => URI

    attr_accessor :ref, :title
  end
end