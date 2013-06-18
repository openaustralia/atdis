module ATDIS
  Document = Struct.new(:ref, :title, :document_url) do
    def self.interpret(data)
      data[:document_url] = URI.parse(data[:document_url]) if data[:document_url]
      
      Document.new(*members.map{|m| data[m.to_sym]})
    end
  end
end