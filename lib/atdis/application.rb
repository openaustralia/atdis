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

    attr_accessor :dat_id, :last_modified_date, :description, :authority,
      :lodgement_date, :determination_date, :status, :notification_start_date, :notification_end_date,
      :officer, :estimated_cost, :more_info_url, :comments_url, :location, :events, :documents, :people

    # TODO Would be nice to generate these dynamically
    attr_reader :last_modified_date_before_type_cast, :more_info_url_before_type_cast,
      :lodgement_date_before_type_cast, :determination_date_before_type_cast,
      :notification_start_date_before_type_cast, :notification_end_date_before_type_cast,
      :comments_url_before_type_cast

    validates :dat_id, :description, :authority, :status, :presence => true
    validates :last_modified_date, :lodgement_date, :determination_date, :presence_before_type_cast => true, :date_time => true
    validates :more_info_url, :presence_before_type_cast => true, :url => true
    # Optional
    validates :notification_start_date, :notification_end_date, :date_time => true

    def last_modified_date=(value)
      @last_modified_date_before_type_cast = value
      @last_modified_date = Application.cast_datetime(value)
    end

    def lodgement_date=(value)
      @lodgement_date_before_type_cast = value
      @lodgement_date = Application.cast_datetime(value)
    end

    def determination_date=(value)
      @determination_date_before_type_cast = value
      @determination_date = Application.cast_datetime(value)
    end

    def notification_start_date=(value)
      @notification_start_date_before_type_cast = value
      @notification_start_date = Application.cast_datetime(value)
    end

    def notification_end_date=(value)
      @notification_end_date_before_type_cast = value
      @notification_end_date = Application.cast_datetime(value)
    end

    def more_info_url=(value)
      @more_info_url_before_type_cast = value
      @more_info_url = Application.cast_uri(value)
    end

    def comments_url=(value)
      @comments_url_before_type_cast = value
      @comments_url = Application.cast_uri(value)
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
