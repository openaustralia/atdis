require "atdis/application"

module ATDIS
  class Response < Model
    set_field_mappings ({
      application: Application
    })

    # This model is only valid if the children are valid
    validates :application, valid: true
  end
end
