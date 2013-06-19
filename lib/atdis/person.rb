module ATDIS
  class Person < Model
    attr_accessor :name, :role, :contact

    def self.interpret(data)
      Person.new(data)
    end
  end
end