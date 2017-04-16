require 'multi_json'
require 'active_model'
require 'date'
require 'multi_json'

module ATDIS
  module TypeCastAttributes
    extend ActiveSupport::Concern

    included do
      class_attribute :attribute_types
    end

    module ClassMethods
      # of the form {section: Fixnum, address: String}
      def set_field_mappings(p)
        define_attribute_methods(p.keys.map{|k| k.to_s})
        # Convert all values to arrays. Doing this for the sake of tidier notation
        self.attribute_types = {}
        p.each do |k,v|
          v = [v] unless v.kind_of?(Array)
          self.attribute_types[k] = v
        end
      end
    end
  end

  ErrorMessage = Struct.new :message, :spec_section do
    def empty?
      message.empty?
    end

    # Make this behave pretty much like a string
    def to_s
      message
    end
  end

  class Model
    include ActiveModel::Validations
    include Validators
    include ActiveModel::AttributeMethods
    include TypeCastAttributes
    attribute_method_suffix '_before_type_cast'
    attribute_method_suffix '='

    attr_reader :attributes, :attributes_before_type_cast
    # Stores any part of the json that could not be interpreted. Usually
    # signals an error if it isn't empty.
    attr_accessor :json_left_overs, :json_load_error
    attr_accessor :url

    validate :json_loaded_correctly!
    validate :json_left_overs_is_empty

    # Partition the data into used and unused by returning [used, unused]
    def self.partition_by_used(data)
      used, unused = {}, {}
      if data.respond_to?(:each)
        data.each do |key, value|
          if attribute_keys.include?(key)
            used[key] = value
          else
            unused[key] = value
          end
        end
      else
        unused = data
      end
      [used, unused]
    end

    def self.read_url(url)
      r = read_json(RestClient.get(url.to_s).to_str)
      r.url = url.to_s
      r
    end

    def self.read_json(text)
      begin
        data = MultiJson.load(text, symbolize_keys: true)
        interpret(data)
      rescue MultiJson::LoadError => e
        a = interpret({response: []})
        a.json_load_error = e.to_s
        a
      end
    end

    def self.interpret(*params)
      used, unused = partition_by_used(*params)
      new(used.merge(json_left_overs: unused))
    end

    def json_loaded_correctly!
      if json_load_error
        errors.add(:json, ErrorMessage["Invalid JSON: #{json_load_error}", nil])
      end
    end

    def json_errors_local
      r = []
      # First show special json error
      if !errors[:json].empty?
        r << [nil, errors[:json]]
      end
      errors.keys.each do |attribute|
        # The :json attribute is special
        if attribute != :json
          e = errors[attribute]
          r << [{attribute => attributes_before_type_cast[attribute.to_s]}, e.map{|m| ErrorMessage["#{attribute} #{m}", m.spec_section]}] unless e.empty?
        end
      end
      r
    end

    def json_errors_in_children
      r = []
      attributes.each do |attribute_as_string, value|
        attribute = attribute_as_string.to_sym
        e = errors[attribute]
        if value.respond_to?(:json_errors)
           r += value.json_errors.map{|a, b| [{attribute => a}, b]}
        elsif value.kind_of?(Array)
          f = value.find{|v| v.respond_to?(:json_errors) && !v.json_errors.empty?}
          r += f.json_errors.map{|a, b| [{attribute => [a]}, b]} if f
        end
      end
      r
    end

    def json_errors
      json_errors_local + json_errors_in_children
    end

    # Have we tried to use this attribute?
    def used_attribute?(a)
      !attributes_before_type_cast[a].nil?
    end

    def json_left_overs_is_empty
      if json_left_overs && !json_left_overs.empty?
        # We have extra parameters that shouldn't be there
        errors.add(:json, ErrorMessage["Unexpected parameters in json data: #{MultiJson.dump(json_left_overs)}", "4"])
      end
    end

    def initialize(params={})
      @attributes, @attributes_before_type_cast = {}, {}
      params.each do |attr, value|
        self.send("#{attr}=", value)
      end if params
    end

    def self.attribute_keys
      attribute_types.keys
    end

    # Does what the equivalent on Activerecord does
    def self.attribute_names
      attribute_types.keys.map{|k| k.to_s}
    end

    def self.cast(value, type)
      # If it's already the correct type (or nil) then we don't need to do anything
      if value.nil? || value.kind_of?(type)
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
      elsif type == Fixnum
        cast_fixnum(value)
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
      @attributes[attr] = Model.cast(value, attribute_types[attr.to_sym][0])
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
        begin
          DateTime.parse(value)
        rescue ArgumentError
          nil
        end
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

    # This casting allows nil values
    def self.cast_fixnum(value)
      value.to_i if value
    end

    def self.cast_geojson(value)
      RGeo::GeoJSON.decode(hash_symbols_to_string(value))
    end

    # Converts {foo: {bar: "yes"}} to {"foo" => {"bar" => "yes"}}
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
