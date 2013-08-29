require 'multi_json'

module ATDIS
  class Application < Model

    attr_accessor :dat_id, :last_modified_date, :description, :authority,
      :lodgement_date, :determination_date, :status, :notification_start_date, :notification_end_date,
      :officer, :estimated_cost, :more_info_url, :comments_url, :location, :events, :documents, :people

    validates_presence_of :dat_id, :last_modified_date

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
      values[:last_modified_date] = iso8601(values[:last_modified_date]) if values[:last_modified_date]
      values[:lodgement_date] = iso8601(values[:lodgement_date]) if values[:lodgement_date]
      values[:determination_date] = iso8601(values[:determination_date]) if values[:determination_date]
      values[:notification_start_date] = iso8601(values[:notification_start_date]) if values[:notification_start_date]
      values[:notification_end_date] = iso8601(values[:notification_end_date]) if values[:notification_end_date]
      values[:more_info_url] = URI.parse(values[:more_info_url]) if values[:more_info_url]
      values[:comments_url] = URI.parse(values[:comments_url]) if values[:comments_url]
      values[:location] = Location.interpret(values[:location]) if values[:location]
      values[:events] = values[:events].map{|e| Event.interpret(e)} if values[:events]
      values[:documents] = values[:documents].map{|d| Document.interpret(d)} if values[:documents]
      values[:people] = values[:people].map{|p| Person.interpret(p)} if values[:people]
      values
    end

  end
end
