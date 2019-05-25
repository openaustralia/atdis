module ATDIS
  module Models
    class Authority < Model
      field_mappings(
        ref:  URI,
        name: String
      )

      # ref is a "Unique Authority Identifier" and should have the form http://www.council.nsw.gov.au/atdis/1.0
      # It should also be consistent for each council.

      # Mandatory attributes
      validates :ref, :name, presence_before_type_cast: { spec_section: "4.3.1" }

      validates :ref, http_url: { spec_section: "4.3.1" }
      validates :ref, format: { with: %r{atdis\/1.0\z}, message: ATDIS::ErrorMessage.new("is not a valid Unique Authority Identifier", "4.3.1") }
    end
  end
end
