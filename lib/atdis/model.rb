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
      # This would be much easier if we knew we only had to support Ruby 1.9 or greater because it has
      # an implementation built in. Because for the time being we need to support Ruby 1.8 as well
      # we'll build an implementation of parsing by hand. Ugh.
      # Referencing http://www.w3.org/TR/NOTE-datetime
      # In section 4.3.1 of ATDIS 1.0.4 it shows two variants of iso 8601, either the full date
      # or the full date with hours, seconds, minutes and timezone. We'll assume that these
      # are the two variants that are allowed.
      if text.match(/^\d\d\d\d-\d\d-\d\d(T\d\d:\d\d:\d\d(Z|(\+|-)\d\d:\d\d))?$/)
        DateTime.parse(text)
      else
        # When it's not a valid iso 8601 date return the original string. This is different than a nil
        # value which represents that the value is missing
        text
      end
    end
  end
end
