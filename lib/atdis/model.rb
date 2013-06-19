require 'active_model'

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
  end
end
