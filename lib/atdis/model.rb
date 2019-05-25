# frozen_string_literal: true

require "multi_json"
require "active_model"
require "date"

module ATDIS
  module TypeCastAttributes
    extend ActiveSupport::Concern

    included do
      class_attribute :attribute_types
    end

    module ClassMethods
      # of the form {section: Integer, address: String}
      def field_mappings(params)
        define_attribute_methods(params.keys.map(&:to_s))
        # Convert all values to arrays. Doing this for the sake of tidier notation
        self.attribute_types = {}
        params.each do |k, v|
          v = [v] unless v.is_a?(Array)
          attribute_types[k] = v
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
    attribute_method_suffix "_before_type_cast"
    attribute_method_suffix "="

    attr_reader :attributes, :attributes_before_type_cast
    # Stores any part of the json that could not be interpreted. Usually
    # signals an error if it isn't empty.
    attr_accessor :json_left_overs, :json_load_error
    attr_accessor :url

    validate :json_loaded_correctly!
    validate :json_left_overs_is_empty

    # Partition the data into used and unused by returning [used, unused]
    def self.partition_by_used(data)
      used = {}
      unused = {}
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
      data = MultiJson.load(text, symbolize_keys: true)
      interpret(data)
    rescue MultiJson::LoadError => e
      a = interpret(response: [])
      a.json_load_error = e.to_s
      a
    end

    def self.interpret(*params)
      used, unused = partition_by_used(*params)
      new(used.merge(json_left_overs: unused))
    end

    def json_loaded_correctly!
      return unless json_load_error

      errors.add(:json, ErrorMessage["Invalid JSON: #{json_load_error}", nil])
    end

    def json_errors_local
      r = []
      # First show special json error
      errors.keys.each do |attribute|
        r << [nil, errors[:json]] unless errors[:json].empty?
        # The :json attribute is special
        next if attribute == :json

        e = errors[attribute]
        next if e.empty?

        r << [
          { attribute => attributes_before_type_cast[attribute.to_s] },
          e.map { |m| ErrorMessage["#{attribute} #{m}", m.spec_section] }
        ]
      end
      r
    end

    def json_errors_in_children
      r = []
      attributes.each do |attribute_as_string, value|
        attribute = attribute_as_string.to_sym
        if value.respond_to?(:json_errors)
          r += value.json_errors.map { |a, b| [{ attribute => a }, b] }
        elsif value.is_a?(Array)
          f = value.find { |v| v.respond_to?(:json_errors) && !v.json_errors.empty? }
          r += f.json_errors.map { |a, b| [{ attribute => [a] }, b] } if f
        end
      end
      r
    end

    def json_errors
      json_errors_local + json_errors_in_children
    end

    # Have we tried to use this attribute?
    def used_attribute?(attribute)
      !attributes_before_type_cast[attribute].nil?
    end

    def json_left_overs_is_empty
      return unless json_left_overs && !json_left_overs.empty?

      # We have extra parameters that shouldn't be there
      errors.add(
        :json,
        ErrorMessage["Unexpected parameters in json data: #{MultiJson.dump(json_left_overs)}", "4"]
      )
    end

    def initialize(params = {})
      @attributes = {}
      @attributes_before_type_cast = {}
      return unless params

      params.each do |attr, value|
        send("#{attr}=", value)
      end
    end

    def self.attribute_keys
      attribute_types.keys
    end

    # Does what the equivalent on Activerecord does
    def self.attribute_names
      attribute_types.keys.map(&:to_s)
    end

    def self.cast(value, type)
      # If it's already the correct type (or nil) then we don't need to do anything
      if value.nil? || value.is_a?(type)
        value
      # Special handling for arrays. When we typecast arrays we actually
      # typecast each member of the array
      elsif value.is_a?(Array)
        value.map { |v| cast(v, type) }
      elsif type == DateTime
        cast_datetime(value)
      elsif type == URI
        cast_uri(value)
      elsif type == String
        cast_string(value)
      elsif type == Integer
        cast_integer(value)
      elsif type == RGeo::GeoJSON
        cast_geojson(value)
      # Otherwise try to use Type.interpret to do the typecasting
      elsif type.respond_to?(:interpret)
        type.interpret(value) if value
      else
        raise
      end
    end

    def self.cast_datetime(value)
      zone = ActiveSupport::TimeZone.new("UTC")
      zone.iso8601(value).to_datetime
    rescue ArgumentError, KeyError
      nil
    end

    def self.cast_uri(value)
      URI.parse(value)
    rescue URI::InvalidURIError
      nil
    end

    def self.cast_string(value)
      value.to_s
    end

    # This casting allows nil values
    def self.cast_integer(value)
      value&.to_i
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
  end
end
