module ATDIS
  class Person < Model
    field_mappings :name => :name,
      :role => :role,
      :contact => :contact
    casting_attributes :name => String,
      :role => String,
      :contact => String
  end
end