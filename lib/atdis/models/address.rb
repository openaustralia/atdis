module ATDIS
  module Models
    class Address < Model
      field_mappings(
        street: String,
        suburb: String,
        postcode: String,
        state: String
      )

      # Mandatory parameters
      validates :street, :suburb, :postcode, :state, presence_before_type_cast: { spec_section: "4.3.3" }

      validates :postcode, format: { with: /\A[0-9]{4}\z/, message: ATDIS::ErrorMessage.new("is not a valid postcode", "4.3.3") }
    end
  end
end
