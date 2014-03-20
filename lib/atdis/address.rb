module ATDIS
  class Address < Model
    set_field_mappings ({
      street: String,
      suburb: String,
      postcode: String
    })
  end
end
