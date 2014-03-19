module ATDIS
  class Person < Model
    set_field_mappings [
      [:name, [String]],
      [:role, [String]],
      [:contact, [String]]
    ]

    # Mandatory parameters
    validates :name, :role, presence_before_type_cast: {spec_section: "4.3.6"}
  end
end
