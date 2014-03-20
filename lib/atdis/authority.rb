module ATDIS
  class Authority < Model
    set_field_mappings ({
      ref:  URI,
      name: String
    })

    # ref is a "Unique Authority Identifier" and should have the form http://www.council.nsw.gov.au/atdis/1.0
    # It should also be consistent for each council.
    # TODO: Check somehow that the authority ref is consistently used

    validates :ref, http_url: {spec_section: "4.2"}
    validates :ref, format: { with: /atdis\/1.0\z/, message: ATDIS::ErrorMessage.new("is not a valid Unique Authority Identifier", "4.2")}
  end
end
