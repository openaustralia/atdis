require 'active_model'
require 'date'

module ATDIS
  module TypeCastAttributes
    extend ActiveSupport::Concern

    included do
      class_attribute :attribute_types
      class_attribute :field_mappings
    end

    module ClassMethods
      # of the form {:section=>[String, {:none_is_nil=>true}], :address=>[String]}
      def casting_attributes(p)
        define_attribute_methods(p.keys.map{|k| k.to_s})
        self.attribute_types = p
      end

      def set_field_mappings(p)
        a, b = translate_field_mappings(p)
        # field_mappings is of the form {:pagination=>{:previous=>:previous_page_no, :pages=>:total_no_pages}}
        self.field_mappings = a
        casting_attributes(b)
      end

      private

      def leaf_array?(v)
        if !v.kind_of?(Array)
          return false
        end
        v.all?{|a| !a.kind_of?(Array)}
      end
      
      def translate_field_mappings(p)
        f = ActiveSupport::OrderedHash.new
        ca = ActiveSupport::OrderedHash.new
        p.each do |k,v|
          if leaf_array?(v)
            f[k] = v[0]
            ca[v.first] = v[1..-1]
          else
            f2, ca2 = translate_field_mappings(v)
            f[k] = f2
            ca = ca.merge(ca2)
          end
        end
        [f, ca]
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
    
    validate :json_left_overs_is_empty

    def self.level_attribute_names(level)
      attribute_types.find_all{|k,v| (v[1] || {})[:level] == level }.map{|k,v| k.to_s}
    end

    def json_attribute(a, new_value, mappings = field_mappings)
      mappings.each do |attribute, v|
        if v == a
          return {attribute => new_value}
        end
        if v.kind_of?(Hash)
          r = json_attribute(a, new_value, v)
          if r
            return {attribute => r}
          end
        end
      end
      nil
    end

    def self.map_field(key, data, mappings)
      mappings.each do |k, v|
        if v == key
          return data[k]
        elsif v.kind_of?(Hash) && data.has_key?(k)
          r = map_field(key, data[k], mappings[k])
          if r
            return r
          end
        end
      end
      nil
    end

    def self.unused_data(data, mappings = field_mappings)
      json_left_overs = {}
      data.each_key do |key|
        if mappings[key]
          if mappings[key].kind_of?(Hash)
            l2 = unused_data(data[key], mappings[key])
            json_left_overs[key] = l2 unless l2.empty?
          end
        else
          json_left_overs[key] = data[key]
        end
      end
      json_left_overs
    end

    def self.attribute_names_from_mappings(mappings)
      result = []
      mappings.each do |k, v|
        if v.kind_of?(Hash)
          result += attribute_names_from_mappings(v)
        else
          result << v
        end
      end
      result
    end

    # Map json structure to our values
    def self.map_fields(data, mappings = field_mappings)
      values = {}
      attribute_names_from_mappings(mappings).each do |attribute|
        values[attribute] = map_field(attribute, data, mappings)
      end
      values
    end

    def json_errors_local
      r = []
      attributes.each do |attribute_as_string, value|
        attribute = attribute_as_string.to_sym
        e = errors[attribute]
        r << [json_attribute(attribute, attributes_before_type_cast[attribute.to_s]), e] unless e.empty?
      end
      r
    end

    def json_errors_in_children
      r = []
      attributes.each do |attribute_as_string, value|
        attribute = attribute_as_string.to_sym
        e = errors[attribute]
        if value.respond_to?(:json_errors)
           r += value.json_errors.map{|a, b| [json_attribute(attribute, a), b]}
        elsif value.kind_of?(Array)
          f = value.find{|v| v.respond_to?(:json_errors) && !v.json_errors.empty?}
          r += f.json_errors.map{|a, b| [json_attribute(attribute, [a]), b]} if f
        end
      end
      r
    end

    def json_errors
      json_errors_local + json_errors_in_children
    end

    # TODO This is doing a similar stepping down into the children that json_errors is doing. Would be nice
    # to extract the commond code to make this less horrible and arbitrary
    def level_used_in_children?(level)
      attributes.each_value do |a|
        if a.respond_to?(:level_used?) && a.level_used?(level)
          return true
        elsif a.kind_of?(Array) && a.any?{|b| b.level_used?(level)}
          return true
        end
      end
      false
    end

    # Have we tried to use this attribute?
    def used_attribute?(a)
      !attributes_before_type_cast[a].nil?
    end

    def level_used_locally?(level)
      self.class.level_attribute_names(level).any?{|a| used_attribute?(a)}
    end

    def level_used?(level)
      level_used_locally?(level) || level_used_in_children?(level)
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

    # Does what the equivalent on Activerecord does
    def self.attribute_names
      attribute_types.keys.map{|k| k.to_s}
    end

    def self.interpret(*params)
      new(map_fields(*params).merge(:json_left_overs => unused_data(*params)))
    end

    def self.cast(value, type, options = {})
      if options[:none_is_nil] && value == "none"
        nil
      # If it's already the correct type then we don't need to do anything
      elsif value.kind_of?(type)
        value
      # Special handling for arrays. When we typecast arrays we actually typecast each member of the array
      elsif value.kind_of?(Array)
        value.map {|v| cast(v, type, options)}
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
      @attributes[attr] = Model.cast(value, attribute_types[attr.to_sym][0], attribute_types[attr.to_sym][1] || {})
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

    # This casting allows nil values
    def self.cast_fixnum(value)
      value.to_i if value
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
