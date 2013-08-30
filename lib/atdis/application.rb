require 'multi_json'

class DateTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    raw_value = record.send("#{attribute}_before_type_cast")
    if raw_value.present? && !value.kind_of?(DateTime)
      record.errors.add(attribute, "is not a valid date")
    end
  end
end

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    raw_value = record.send("#{attribute}_before_type_cast")
    if raw_value.present? && !value.kind_of?(URI)
      record.errors.add(attribute, "is not a valid URL")
    end
  end
end

# Take into account the value before type casting
class PresenceBeforeTypeCastValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    raw_value = record.send("#{attribute}_before_type_cast")
    unless raw_value.present?
      record.errors.add(attribute, "can't be blank")
    end
  end
end
 
module ATDIS
  class Application < Model
    include ActiveModel::AttributeMethods
    attribute_method_suffix '_before_type_cast'
    define_attribute_methods ['last_modified_date', 'more_info_url', 'lodgement_date', 'determination_date',
      'notification_start_date', 'notification_end_date', 'comments_url']

    attr_accessor :dat_id, :description, :authority, :status, :officer, :estimated_cost, :location,
      :events, :documents, :people

    validates :dat_id, :description, :authority, :status, :presence => true
    validates :last_modified_date, :lodgement_date, :determination_date, :presence_before_type_cast => true, :date_time => true
    validates :more_info_url, :presence_before_type_cast => true, :url => true
    # Optional
    validates :notification_start_date, :notification_end_date, :date_time => true

    # TODO Validate associated like locations, events, documents, people

    def initialize(params = {})
      @attributes, @attributes_before_type_cast = {}, {}
      super(params)
    end

    def last_modified_date=(value)
      @attributes_before_type_cast[:last_modified_date] = value
      @attributes[:last_modified_date] = Application.cast(value, DateTime)
    end

    def lodgement_date=(value)
      @attributes_before_type_cast[:lodgement_date] = value
      @attributes[:lodgement_date] = Application.cast(value, DateTime)
    end

    def determination_date=(value)
      @attributes_before_type_cast[:determination_date] = value
      @attributes[:determination_date] = Application.cast(value, DateTime)
    end

    def notification_start_date=(value)
      @attributes_before_type_cast[:notification_start_date] = value
      @attributes[:notification_start_date] = Application.cast(value, DateTime)
    end

    def notification_end_date=(value)
      @attributes_before_type_cast[:notification_end_date] = value
      @attributes[:notification_end_date] = Application.cast(value, DateTime)
    end

    def more_info_url=(value)
      @attributes_before_type_cast[:more_info_url] = value
      @attributes[:more_info_url] = Application.cast(value, URI)
    end

    def comments_url=(value)
      @attributes_before_type_cast[:comments_url] = value
      @attributes[:comments_url] = Application.cast(value, URI)
    end

    def self.convert(data)
      values = {}
      # Map json structure to our values
      values = values.merge(data[:info]) if data[:info]
      values = values.merge(data[:reference]) if data[:reference]
      values[:location] = data[:location] if data[:location]
      values[:events] = data[:events] if data[:events]
      values[:documents] = data[:documents] if data[:documents]
      values[:people] = data[:people] if data[:people]

      # Convert values (if required)
      values[:location] = Location.interpret(values[:location]) if values[:location]
      values[:events] = values[:events].map{|e| Event.interpret(e)} if values[:events]
      values[:documents] = values[:documents].map{|d| Document.interpret(d)} if values[:documents]
      values[:people] = values[:people].map{|p| Person.interpret(p)} if values[:people]
      values
    end

    private

    def attribute(attr)
      @attributes[attr.to_sym]
    end

    def attribute_before_type_cast(attr)
      @attributes_before_type_cast[attr.to_sym]
    end
  end
end
