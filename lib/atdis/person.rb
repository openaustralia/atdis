module ATDIS
  Person = Struct.new(:name, :role, :contact) do
    def self.interpret(data)
      Person.new(*members.map{|m| data[m.to_sym]})
    end
  end
end