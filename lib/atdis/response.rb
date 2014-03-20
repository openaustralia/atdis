require "atdis/application"

module ATDIS
  class Response < Model
    # TODO When we remove support for Ruby 1.8 we can convert field_mappings back to a hash
    # which is much more readable
    set_field_mappings ({
      application: Application
    })

    # This model is only valid if the children are valid
    validates :application, valid: true
  end
end
