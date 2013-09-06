module ATDIS
  class Document < Model
    field_mappings2 :ref => [:ref, String],
      :title => [:title, String],
      :document_url => [:document_url, URI]
  end
end