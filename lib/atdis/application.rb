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
    define_attribute_methods ['last_modified_date', 'more_info_url', 'lodgement_date', 'determination_date',
      'notification_start_date', 'notification_end_date', 'comments_url', 'description', 'dat_id', 'authority',
      'status', 'officer', 'estimated_cost']

    def attribute_types
      {
        'last_modified_date' => DateTime,
        'lodgement_date' => DateTime,
        'determination_date' => DateTime,
        'notification_start_date' => DateTime,
        'notification_end_date' => DateTime,
        'more_info_url' => URI,
        'comments_url' => URI,
        'description' => String,
        'dat_id' => String,
        'authority' => String,
        'status' => String,
        'officer' => String,
        'estimated_cost' => String
      }
    end

    attr_accessor :location, :events, :documents, :people

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
  end
end
