require 'multi_json'
 
module ATDIS
  class Application < Model
    casting_attributes :last_modified_date => DateTime,
      :lodgement_date => DateTime,
      :determination_date => DateTime,
      :notification_start_date => DateTime,
      :notification_end_date => DateTime,
      :more_info_url => URI,
      :comments_url => URI,
      :description => String,
      :dat_id => String,
      :authority => String,
      :status => String,
      :officer => String,
      :estimated_cost => String

    attr_accessor :location, :events, :documents, :people

    validates :dat_id, :description, :authority, :status, :presence => true
    validates :last_modified_date, :lodgement_date, :determination_date, :presence_before_type_cast => true, :date_time => true
    validates :more_info_url, :presence_before_type_cast => true, :url => true
    # Optional
    validates :notification_start_date, :notification_end_date, :date_time => true

    # TODO Validate associated like locations, events, documents, people

    VALID_INFO_FIELDS = [:dat_id, :last_modified_date, :description, :authority, :lodgement_date, :determination_date,
        :status, :notification_start_date, :notification_end_date, :officer, :estimated_cost]
    VALID_REFERENCE_FIELDS = [:more_info_url, :comments_url]

    def self.convert(data)
      values = {}
      # Map json structure to our values
      if data[:info]
        data[:info].each do |key, value|
          if VALID_INFO_FIELDS.include?(key)
            values[key] = value
            data[:info].delete(key)
          end
        end
        data.delete(:info) if data[:info].empty?
      end
      if data[:reference]
        data[:reference].each do |key, value|
          if VALID_REFERENCE_FIELDS.include?(key)
            values[key] = value
            data[:reference].delete(key)
          end
        end
        data.delete(:reference) if data[:reference].empty?
      end
      if data[:location]
        values[:location] = data[:location]
        data.delete(:location)
      end
      if data[:events]
        values[:events] = data[:events]
        data.delete(:events)
      end
      if data[:documents]
        values[:documents] = data[:documents]
        data.delete(:documents)
      end
      if data[:people]
        values[:people] = data[:people]
        data.delete(:people)
      end

      # Convert values (if required)
      values[:location] = Location.interpret(values[:location]) if values[:location]
      values[:events] = values[:events].map{|e| Event.interpret(e)} if values[:events]
      values[:documents] = values[:documents].map{|d| Document.interpret(d)} if values[:documents]
      values[:people] = values[:people].map{|p| Person.interpret(p)} if values[:people]
      [values, data]
    end
  end
end
