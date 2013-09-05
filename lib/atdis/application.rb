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

    VALID_FIELDS = {
      :info => [:dat_id, :last_modified_date, :description, :authority, :lodgement_date, :determination_date,
        :status, :notification_start_date, :notification_end_date, :officer, :estimated_cost],
      :reference => [:more_info_url, :comments_url]
    }

    def self.convert(data)
      values = {}
      # Map json structure to our values
      [:info, :reference].each do |a|
        if data[a]
          data[a].each do |key, value|
            if VALID_FIELDS[a].include?(key)
              values[key] = value
              data[a].delete(key)
            end
          end
          data.delete(a) if data[a].empty?
        end
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

      values[:json_left_overs] = data
      values
    end
  end
end
