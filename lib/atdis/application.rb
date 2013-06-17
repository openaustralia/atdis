require 'multi_json'
require 'date'

module ATDIS
  Application = Struct.new(:dat_id, :last_modified_date, :description, :authority,
      :lodgement_date, :determination_date, :status, :notification_start_date, :notification_end_date,
      :officer, :estimated_cost, :more_info_url, :comments_url, :location) do

    def self.interpret(data)
      values = {}
      # Map json structure to our values
      values = values.merge(data[:info]) if data[:info]
      values = values.merge(data[:reference]) if data[:reference]
      values[:location] = data[:location]

      # Convert values (if required)
      values[:last_modified_date] = DateTime.parse(values[:last_modified_date]) if values[:last_modified_date]
      values[:lodgement_date] = DateTime.parse(values[:lodgement_date]) if values[:lodgement_date]
      values[:determination_date] = DateTime.parse(values[:determination_date]) if values[:determination_date]
      values[:notification_start_date] = DateTime.parse(values[:notification_start_date]) if values[:notification_start_date]
      values[:notification_end_date] = DateTime.parse(values[:notification_end_date]) if values[:notification_end_date]
      values[:more_info_url] = URI.parse(values[:more_info_url]) if values[:more_info_url]
      values[:comments_url] = URI.parse(values[:comments_url]) if values[:comments_url]
      values[:location] = Location.interpret(values[:location]) if values[:location]

      Application.new(*members.map{|m| values[m.to_sym]})
    end
  end
end
