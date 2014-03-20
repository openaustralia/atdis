module ATDIS
  class Address < Model
    set_field_mappings ({
      street: String,
      suburb: String,
      postcode: String
    })

    validates :postcode, format: { with: /\A[0-9]{4}\z/, message: ATDIS::ErrorMessage.new("is not a valid postcode", "4.3.3")}
  end
end
