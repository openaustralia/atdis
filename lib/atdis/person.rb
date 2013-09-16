module ATDIS
  class Person < Model
    field_mappings [
      [:name, [:name, String]],
      [:role, [:role, String]],
      [:contact, [:contact, String]]
    ]

    # Mandatory parameters
    validates :name, :role, :presence_before_type_cast => true    
  end
end