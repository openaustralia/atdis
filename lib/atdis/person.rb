module ATDIS
  class Person < Model
    attr_accessor :name, :role, :contact

    VALID_FIELDS = {
      :name => :name,
      :role => :role,
      :contact => :contact
    }

    def self.convert(data)
      map_fields2(VALID_FIELDS, data)
    end
  end
end