require 'multi_json'
require 'date'

module ATDIS
  class Application
    attr_accessor :dat_id, :last_modified_date, :description, :authority,
      :lodgement_date, :determination_date, :status, :notification_start_date, :notification_end_date,
      :officer, :estimated_cost, :more_info_url, :location

    def self.parse(text)
      interpret(MultiJson.load(text, :symbolize_keys => true))
    end

    def self.interpret(data)
      a = Application.new
      
      if data[:info]
        a.dat_id = data[:info][:dat_id]
        a.last_modified_date = DateTime.parse(data[:info][:last_modified_date]) if data[:info][:last_modified_date]
        a.description = data[:info][:description]
        a.authority = data[:info][:authority]
        a.lodgement_date = DateTime.parse(data[:info][:lodgement_date]) if data[:info][:lodgement_date]
        a.determination_date = DateTime.parse(data[:info][:determination_date]) if data[:info][:determination_date]
        a.status = data[:info][:status]
        a.notification_start_date = DateTime.parse(data[:info][:notification_start_date]) if data[:info][:notification_start_date]
        a.notification_end_date = DateTime.parse(data[:info][:notification_end_date]) if data[:info][:notification_end_date]
        a.officer = data[:info][:officer]
        a.estimated_cost = data[:info][:estimated_cost]
      end
      a.more_info_url = data[:reference][:more_info_url] if data[:reference]
      a.location = Location.interpret(data[:location]) if data[:location]
      a
    end
  end
end
