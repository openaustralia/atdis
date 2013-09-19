module ATDIS
  class Person < Model
    set_field_mappings [
      [:name, [:name, String, {:level => 2}]],
      [:role, [:role, String, {:level => 2}]],
      [:contact, [:contact, String, {:level => 2}]]
    ]

    # Mandatory parameters
    validates :name, :role, :presence_before_type_cast => {:spec_section => "4.3.6"}    
  end
end