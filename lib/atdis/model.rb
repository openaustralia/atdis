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

    def self.cast(value, type)
      if type == DateTime
        cast_datetime(value)
      elsif type == URI
        cast_uri(value)
      elsif type == String
        cast_string(value)
      else
        raise
      end
    end

    private

    def self.cast_datetime(value)
      if value.kind_of?(DateTime)
        value
      else
        # This would be much easier if we knew we only had to support Ruby 1.9 or greater because it has
        # an implementation built in. Because for the time being we need to support Ruby 1.8 as well
        # we'll build an implementation of parsing by hand. Ugh.
        # Referencing http://www.w3.org/TR/NOTE-datetime
        # In section 4.3.1 of ATDIS 1.0.4 it shows two variants of iso 8601, either the full date
        # or the full date with hours, seconds, minutes and timezone. We'll assume that these
        # are the two variants that are allowed.
        if value.respond_to?(:match) && value.match(/^\d\d\d\d-\d\d-\d\d(T\d\d:\d\d:\d\d(Z|(\+|-)\d\d:\d\d))?$/)
          DateTime.parse(value)
        end
      end
    end

    def self.cast_uri(value)
      if value.kind_of?(URI)
        value
      else
        begin
          URI.parse(value)
        rescue URI::InvalidURIError
          nil
        end
      end
    end

    def self.cast_string(value)
      value.to_s
    end
  end
end
