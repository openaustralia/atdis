# frozen_string_literal: true

module ATDIS
  module Models
    class TorrensTitle < Model
      field_mappings(
        lot: String,
        section: String,
        dpsp_id: String
      )

      # Mandatory attributes
      # section is not in this list because it can be null (even though it is mandatory)
      validates :lot, :dpsp_id, presence_before_type_cast: { spec_section: "4.3.3" }
      # TODO: Provide warning if dpsp_id doesn't start with "DP" or "SP"

      validate :section_can_not_be_empty_string

      def section_can_not_be_empty_string
        return unless section == ""

        errors.add(:section, ATDIS::ErrorMessage.new("can't be blank", "4.3.3"))
      end
    end
  end
end
