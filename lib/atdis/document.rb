module ATDIS
  class Document < Model
    field_mappings [
      [:ref, [:ref, String]],
      [:title, [:title, String]],
      [:document_url, [:document_url, URI]]
    ]

    # Mandatory parameters
    validates :ref, :title, :document_url, :presence_before_type_cast => true
    # Other validations
    validates :document_url, :http_url => true
  end
end