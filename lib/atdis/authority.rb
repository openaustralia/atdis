module ATDIS
  class Authority < Model
    set_field_mappings ({
      ref:  URI,
      name: String
    })

    # ref is a "Unique Authority Identifier" and should have the form http://www.council.nsw.gov.au/atdis/1.0
    # It should also be consistent for each council.
    # TODO: Check somehow that the authority ref is consistently used
  end
end
