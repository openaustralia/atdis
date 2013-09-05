module ATDIS
  class Person < Model
    attr_accessor :name, :role, :contact

    field_mappings :name => :name,
      :role => :role,
      :contact => :contact
  end
end