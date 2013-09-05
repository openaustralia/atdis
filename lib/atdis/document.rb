module ATDIS
  class Document < Model
    casting_attributes :document_url => URI

    attr_accessor :ref, :title

    VALID_FIELDS = {
      :ref => :ref,
      :title => :title,
      :document_url => :document_url
    }
    
    # TODO Do proper mapping of json parameters to our parameters
    def self.convert(data)
      map_fields2(VALID_FIELDS, data)
    end
  end
end