# frozen_string_literal: true

module ATDIS
  module Models
    class Document < Model
      field_mappings(
        ref: String,
        title: String,
        document_url: URI
      )

      # Mandatory parameters
      validates :ref, :title, :document_url, presence_before_type_cast: { spec_section: "4.3.5" }
      # Other validations
      validates :document_url, http_url: { spec_section: "4.3.5" }
    end
  end
end
