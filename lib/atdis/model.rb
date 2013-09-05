require 'active_model'
require 'date'

module ATDIS
  module TypeCastAttributes
    extend ActiveSupport::Concern

    included do
      class_attribute :attribute_types
      class_attribute :valid_fields
    end

    module ClassMethods
      def casting_attributes(p)
        define_attribute_methods(p.keys.map{|k| k.to_s})
        self.attribute_types = p
      end

      def field_mappings(p)
        self.valid_fields = p
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
      new(map_fields(valid_fields, *params))
    end

    # Map json structure to our values
    def self.map_fields(valid_fields, data)
      values = {:json_left_overs => {}}
      data.each_key do |key|
        if valid_fields[key]
          if valid_fields[key].kind_of?(Hash)
            v2 = map_fields(valid_fields[key], data[key])
            l2 = v2.delete(:json_left_overs)
            values = values.merge(v2)
            values[:json_left_overs][key] = l2 unless l2.empty?
          else
            values[valid_fields[key]] = data[key]
          end
        else
          values[:json_left_overs][key] = data[key]
        end
      end
      values
    end

    def self.cast(value, type)
      # If it's already the correct type then we don't need to do anything
      if value.kind_of?(type)
        value
      # Special handling for arrays. When we typecast arrays we actually typecast each member of the array
      elsif value.kind_of?(Array)
        value.map {|v| cast(v, type)}
      elsif type == DateTime
        cast_datetime(value)
      elsif type == URI
        cast_uri(value)
      elsif type == String
        cast_string(value)
      elsif type == RGeo::GeoJSON
        cast_geojson(value)
      # Otherwise try to use Type.interpret to do the typecasting
      elsif type.respond_to?(:interpret)
        type.interpret(value) if value
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

    def self.cast_uri(value)
      begin
        URI.parse(value)
      rescue URI::InvalidURIError
        nil
      end
    end

    def self.cast_string(value)
      value.to_s
    end

    def self.cast_geojson(value)
      RGeo::GeoJSON.decode(hash_symbols_to_string(value))
    end

    # Converts {:foo => {:bar => "yes"}} to {"foo" => {"bar" => "yes"}}
    def self.hash_symbols_to_string(hash)
      if hash.respond_to?(:each_pair)
        result = {}
        hash.each_pair do |key, value|
          result[key.to_s] = hash_symbols_to_string(value)
        end
        result
      else
        hash
      end
    end
  end
end
