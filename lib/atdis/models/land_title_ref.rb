require "atdis/models/torrens_title"

module ATDIS
  module Models
    class LandTitleRef < Model
      set_field_mappings ({
        torrens: TorrensTitle
      })

      # This model is only valid if the children are valid
      validates :torrens, valid: true
    end
  end
end
