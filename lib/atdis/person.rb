module ATDIS
  class Person < Model
    field_mappings :name => [:name, String],
      :role => [:role, String],
      :contact => [:contact, String]
  end
end