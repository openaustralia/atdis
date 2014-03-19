require 'multi_json'

module ATDIS
  class Response < Model
    # TODO When we remove support for Ruby 1.8 we can convert field_mappings back to a hash
    # which is much more readable
    set_field_mappings [
      [:application, [:application, Application]]
    ]

    validates :application, valid: true
  end
end
