require 'active_model'
require 'date'

module ATDIS
  class Model
    include ActiveModel::Validations

    def initialize(params={})
      params.each do |attr, value|
        self.send("#{attr}=", value)
      end if params
    end

    def self.interpret(*params)
      new(convert(*params))
    end

    # By default do no conversion. You will usually override this.
    def self.convert(data)
      data
    end

    # TODO We're currently far more forgiving here then we should be. It will accept all
    # kinds of different date formats. Tighten this up only accept iso8601.
    def self.iso8601(text)
      DateTime.parse(text)
    end
  end
end
