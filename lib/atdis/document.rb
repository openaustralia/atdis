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
      values, json_left_overs = map_fields(VALID_FIELDS, data)
      values.merge(:json_left_overs => json_left_overs)
    end
  end
end