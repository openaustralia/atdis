module ATDIS
  class Person < Model
    attr_accessor :name, :role, :contact

    Person.valid_fields = {
      :name => :name,
      :role => :role,
      :contact => :contact
    }
  end
end