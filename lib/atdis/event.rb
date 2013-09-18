module ATDIS
  class Event < Model
    set_field_mappings [
      [:id, [:id, String, {:level => 1}]],
      [:date, [:date, DateTime, {:level => 1}]],
      [:description, [:description, String, {:level => 1}]],
      [:event_type, [:event_type, String, {:level => 1}]],
      [:status, [:status, String, {:level => 1}]]
    ]
    
    # Mandatory parameters
    validates :id, :date, :description, :presence_before_type_cast => true
  end

  # TODO Check that :id is unique within an authority
  
end
