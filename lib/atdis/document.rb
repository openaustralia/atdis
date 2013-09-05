module ATDIS
  class Document < Model
    casting_attributes :ref => String,
      :title => String,
      :document_url => URI

    field_mappings :ref => :ref,
      :title => :title,
      :document_url => :document_url
  end
end