module ATDIS
  class Document < Model
    casting_attributes :document_url => URI

    attr_accessor :ref, :title

    # TODO Do proper mapping of json parameters to our parameters
    def self.convert(data)
      data.merge(:json_left_overs => {})
    end
  end
end