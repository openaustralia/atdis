module ATDIS
  class Document < Model
    set_field_mappings [
      [:ref, [:ref, String]],
      [:title, [:title, String]],
      [:document_url, [:document_url, URI]]
    ]

    # Mandatory parameters
    validates :ref, :title, :document_url, presence_before_type_cast: {spec_section: "4.3.5"}
    # Other validations
    validates :document_url, http_url: {spec_section: "4.3.5"}
  end
end
