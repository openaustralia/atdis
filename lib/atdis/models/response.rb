require "atdis/models/application"

module ATDIS
  module Models
    class Response < Model
      set_field_mappings ({
        application: Application
      })

      validates :application, presence_before_type_cast: {spec_section: "4.3"}

      # This model is only valid if the children are valid
      validates :application, valid: true
    end
  end
end
