module ATDIS
  class Person < Model
    attr_accessor :name, :role, :contact

    VALID_FIELDS = {
      :name => :name,
      :role => :role,
      :contact => :contact
    }

    # TODO Do proper mapping of json parameters to our parameters
    def self.convert(data)
      values, json_left_overs = map_fields(VALID_FIELDS, data)
      values.merge(:json_left_overs => json_left_overs)
    end
  end
end