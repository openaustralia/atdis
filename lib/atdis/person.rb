module ATDIS
  class Person < Model
    field_mappings2 :name => [:name, String],
      :role => [:role, String],
      :contact => [:contact, String]
  end
end