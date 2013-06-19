require 'active_model'

module ATDIS
  class Model
    include ActiveModel::Validations

    def initialize(params={})
      params.each do |attr, value|
        self.send("#{attr}=", value)
      end if params
    end
  end
end
