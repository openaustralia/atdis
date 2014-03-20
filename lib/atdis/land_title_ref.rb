module ATDIS
  class LandTitleRef < Model
    set_field_mappings ({
      lot:     String,
      section: [String, {none_is_nil: true}],
      dpsp_id: String 
    })

    validates :lot, :section, :dpsp_id, presence_before_type_cast: {spec_section: "4.3.3"}
    # TODO: Provide warning if dpsp_id doesn't start with "DP" or "SP"
  end
end
