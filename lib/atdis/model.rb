require 'active_model'
require 'date'

module ATDIS
  module TypeCastAttributes
    extend ActiveSupport::Concern

    included do
      class_attribute :attribute_types
    end

    module ClassMethods
      def casting_attributes(p)
        define_attribute_methods(p.keys.map{|k| k.to_s})
        self.attribute_types = p
      end
    end
  end

  class Model
    include ActiveModel::Validations
    include Validators
    include ActiveModel::AttributeMethods
    include TypeCastAttributes
    attribute_method_suffix '_before_type_cast'
    attribute_method_suffix '='

    attr_reader :attributes
    # Stores any part of the json that could not be interpreted. Usually
    # signals an error if it isn't empty.
    attr_accessor :json_left_overs

    validate :json_left_overs_is_empty

    def json_left_overs_is_empty
      unless json_left_overs.empty?
        # We have extra parameters that shouldn't be there
        errors.add(:json, "Unexpected parameters in json data: #{MultiJson.dump(json_left_overs)}")
      end
    end

    def initialize(params={})
      @attributes, @attributes_before_type_cast = {}, {}
      params.each do |attr, value|
        self.send("#{attr}=", value)
      end if params
    end

    # Does what the equivalent on Activerecord does
    def self.attribute_names
      attribute_types.keys.map{|k| k.to_s}
    end

    def self.interpret(*params)
      new(convert(*params))
    end

    def self.map_fields2(valid_fields, data)
      values, json_left_overs = map_fields(valid_fields, data)
      values.merge(:json_left_overs => json_left_overs)
    end

    # Map json structure to our values
    def self.map_fields(valid_fields, data)
      values = {}
      left_overs = {}
      data.each_key do |key|
        if valid_fields[key]
          if valid_fields[key].kind_of?(Hash)
            v2, l2 = map_fields(valid_fields[key], data[key])
            values = values.merge(v2)
            left_overs[key] = l2 unless l2.empty?
          else
            values[valid_fields[key]] = data[key]
          end
        else
          left_overs[key] = data[key]
        end
      end
      [values, left_overs]
    end

    # By default do no conversion. You will usually override this.
    def self.convert(data)
      raise "Implement self.convert in your class"
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

    def attribute(attr)
      @attributes[attr]
    end

    def attribute_before_type_cast(attr)
      @attributes_before_type_cast[attr]
    end

    def attribute=(attr, value)
      @attributes_before_type_cast[attr] = value
      @attributes[attr] = Model.cast(value, attribute_types[attr.to_sym])
    end

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
