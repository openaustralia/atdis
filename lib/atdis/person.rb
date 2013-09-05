module ATDIS
  class Person < Model
    attr_accessor :name, :role, :contact

    # TODO Do proper mapping of json parameters to our parameters
    def self.convert(data)
      data.merge(:json_left_overs => {})
    end
  end
end