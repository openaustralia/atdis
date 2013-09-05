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

    # How the json parameters map to our attributes
    VALID_FIELDS = {
      :info => {
        :dat_id => :dat_id,
        :last_modified_date => :last_modified_date,
        :description => :description,
        :authority => :authority,
        :lodgement_date => :lodgement_date,
        :determination_date => :determination_date,
        :status => :status,
        :notification_start_date => :notification_start_date,
        :notification_end_date => :notification_end_date,
        :officer => :officer,
        :estimated_cost => :estimated_cost
      },
      :reference => {
        :more_info_url => :more_info_url,
        :comments_url => :comments_url
      },
      :location => :location,
      :events => :events,
      :documents => :documents,
      :people => :people
    }

    def self.map_fields(valid_fields, data)
      values = {}
      # Map json structure to our values
      valid_fields.each do |key1, value1|
        if data[key1]
          if value1.kind_of?(Hash)
            data[key1].each do |key2, value2|
              if value1.has_key?(key2)
                new_key = value1[key2]
                values[new_key] = value2
                data[key1].delete(key2)
              end
            end
            data.delete(key1) if data[key1].empty?
          else
            values[value1] = data[key1]
            data.delete(key1)
          end
        end
      end
      values
    end

    def self.convert(data)
      values = map_fields(VALID_FIELDS, data)

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
