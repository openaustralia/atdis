module ATDIS
  module Models
    class Address < Model
      set_field_mappings ({
        street: String,
        suburb: String,
        postcode: String
      })

      # Mandatory parameters
      validates :street, :suburb, :postcode, presence_before_type_cast: {spec_section: "4.3.3"}

      validates :postcode, format: { with: /\A[0-9]{4}\z/, message: ATDIS::ErrorMessage.new("is not a valid postcode", "4.3.3")}
    end
  end
end