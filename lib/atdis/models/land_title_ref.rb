require "atdis/models/torrens_title"

module ATDIS
  module Models
    class LandTitleRef < Model
      field_mappings(
        torrens: TorrensTitle,
        other:   Hash
      )

      # This model is only valid if the children are valid
      validates :torrens, valid: true

      validate :check_title_presence

      def check_title_presence
        if torrens.nil? && other.nil?
          errors.add(:torrens, ATDIS::ErrorMessage.new("or other needs be present", "4.3.3"))
        end
        return unless torrens && other

        errors.add(:torrens, ATDIS::ErrorMessage.new("and other can't both be present", "4.3.3"))
      end
    end
  end
end
